require 'sinatra/base'
require 'citero'

class ApplicationController < Sinatra::Base
  class PrimoRecordError < ArgumentError
  end

  def initialize
    super()
    @metrics ||= Metrics.new
  end

  set :show_exceptions, false
  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  helpers do
    def whitelisted_calling_systems
      @whitelisted_calling_systems ||= %w(primo)
    end
  end

  before do
    # Skip setting the instance vars if it's just the healthcheck
    pass if %w[healthcheck].include?(request.path_info.split('/')[1]) || request.path_info == '/'
    @local_id, @institution, @cite_to = (params[:local_id] || request.path_info.split('/').last), params[:institution], push_format(params[:cite_to])
    @calling_system = params[:calling_system] if whitelisted_calling_systems.include?(params[:calling_system])
    raise ArgumentError, 'Missing required params. All params required: local_id, institution, cite_to, calling_system' if missing_params?
    raise PrimoRecordError, "Could not find Primo record with id: #{@local_id}" if primo.error?
  end

  # Healthcheck
  get('/healthcheck') do
    content_type :json
    return { success: true }.to_json
  end

  # Citation Data Viewer
  get('/m/:local_id') do
    erb :data_viewer, locals: { csf: csf, primo_api_url: primo.pnx_json_api_endpoint }
  end

  # Main route
  get('/:local_id') do
    # Should we push to an external citation system or download the file?
    @cite_to.download? ? download : push_to_external
  end

  error ArgumentError do
    status 400
    erb :error
  end

  error PrimoRecordError do
    status 422
    erb :error
  end

  not_found do
    status 404
    erb :error
  end

private

  # Downloads a file with the citation
  def download
    content_type @cite_to.mimetype
    attachment(@cite_to.filename)
    csf.force_encoding('UTF-8')
  end

  # Push to external system depending on how the
  # external system API expects it by
  # 1) Redirecting with a callback url which
  # sends the external system back to push_to_cite;
  # 2) Redirecting to the openurl data; or
  # 3) Render the form and post with Javascript
  def push_to_external
    if !params.has_key?(:callback) && @cite_to.redirect_to_external?
      redirect @cite_to.action + callback, 303
    elsif @cite_to.to_sym === :openurl
      if primo.openurl
        redirect primo.openurl, 303
      else
        raise ArgumentError, "OpenURL is nil for record ID: #{@local_id}"
      end
    else
      erb :post_form, locals: { csf: csf }
    end
  end

  # Whitelist available formats and forward to relevant classes
  def push_format(cite_to)
    push_format = cite_to.to_sym unless cite_to.nil?
    case push_format
      when :endnote
        PushFormats::Endnote.new
      when :refworks
        PushFormats::Refworks.new
      when :ris
        PushFormats::Ris.new
      when :bibtex
        PushFormats::Bibtex.new
      when :openurl
        PushFormats::Openurl.new
      else raise ArgumentError, "Invalid or missing push format: #{cite_to}"
    end
  end

  # This URL that you are currently on is also the callback URL
  # but in the case of the callback we always want to render, so flag it!
  def callback
    @callback ||= ERB::Util.url_encode("#{request.url}&callback")
  end

  # Require params
  def missing_params?
    !(@institution && @local_id && @cite_to && @calling_system)
  end

  # Make a call to Primo to get the PNX record
  def primo
    @primo ||= CallingSystems::Primo.new(@local_id, @institution)
  end

  def csf
    @csf ||= Citero.map(primo.get_pnx_json).from_pnx_json.send("to_#{@cite_to.to_format}".to_sym)
  end

end
