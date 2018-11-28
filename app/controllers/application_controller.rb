require 'sinatra/base'
require 'citero'

class ApplicationController < Sinatra::Base
  set :show_exceptions, false
  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  before do
    # Skip setting the instance vars if it's just the healthcheck
    pass if %w[healthcheck].include?(request.path_info.split('/')[1])
    # Get external_id if passed in url as external_id= or if is the last path value
    @external_id = (params[:external_id] || request.path_info.split('/').last)
    halt 400, error_messages[:argument_error] if !set_vars_from_params
    halt 422, error_messages[:primo_record_error] if primo.error? && !@external_id.is_a?(Array)
    halt 400, error_messages[:too_many_records_error] if @external_id.is_a?(Array) && @external_id.count > 10
    @records = gather_citero_records
  end

  helpers do
    def change_querystring_format(cite_to)
      request.query_string.gsub("cite_to=#{params[:cite_to]}", "cite_to=#{cite_to}")
    end
  end

  # Healthcheck
  get('/healthcheck') do
    content_type :json
    return { success: true }.to_json
  end

  # Citation Data Viewer
  get('/m') do
    erb :data_viewer, locals: { csf: citations, primo_api_url: primo.pnx_json_api_endpoint }
  end

  get('/openurl/:external_id') do
    halt 400 unless params[:cite_to] === 'json'
    content_type :json
    return { openurl: primo.openurl }.to_json
  end

  get('/:external_id') do
    redirect "/?#{request.query_string}"
  end

  get('/') do
    if params[:cite_to] === 'json'
      content_type :json
      records_with_keys = @records.map { |r| [r.external_id, r.csf_object] }
      return Hash[*records_with_keys.flatten].to_json
    else
      download_or_push
    end
  end

  error 400..500 do
    unless response.status === 404
      erb :error, locals: { external_id: @external_id, msg: response.body&.first }
    else
      erb :error, locals: { external_id: @external_id, msg: error_messages[:not_found_error] }
    end
  end

private

  def download_or_push
    # Should we push to an external citation system or download the file?
    @cite_to.download? ? download : push_to_external
  end

  # Downloads a file with the citation
  def download
    content_type @cite_to.mimetype
    attachment(@cite_to.filename)
    citations.force_encoding('UTF-8')
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
        halt 422, error_messages[:openurl_not_found_error]
      end
    else
      erb :post_form, locals: { csf: citations }
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
      when :json
        PushFormats::Openurl.new # Dummy val, doesn't matter
      else halt 400, error_messages[:argument_error]
    end
  end

  # This URL that you are currently on is also the callback URL
  # but in the case of the callback we always want to render, so flag it!
  def callback
    @callback ||= ERB::Util.url_encode("#{request.url}&callback")
  end

  def set_vars_from_params
    @institution, @cite_to = (params[:institution] || default_institution), push_format(params[:cite_to])
    @calling_system = (whitelist_calling_system(params[:calling_system]) || default_calling_system)
    return @institution && @cite_to && @calling_system && @external_id
  end

  def default_institution
    ENV['DEFAULT_INSTITUTION'] || 'NYU'
  end

  def default_calling_system
    ENV['DEFAULT_CALLING_SYSTEM'] || 'primo'
  end

  def gather_citero_records(records = [])
    [@external_id].flatten.each_with_index do |external_id, idx|
      record = Citero.map(primo(external_id).get_pnx_json).from_pnx_json
      records << OpenStruct.new(id: idx, external_id: external_id, csf_object: record.csf.csf, citation: record.send("to_#{@cite_to.to_format}".to_sym))
    end
    records
  end

  def citations
    [gather_citero_records.map { |r| r.citation }].flatten.join("\n")
  end

  def whitelist_calling_system(calling_system)
    calling_system if whitelisted_calling_systems.include?(calling_system)
  end

  def whitelisted_calling_systems
    @whitelisted_calling_systems ||= %w(primo)
  end

  def primo(id = @external_id, institution = @institution)
    CallingSystems::Primo.new(id, institution)
  end

  def error_messages
    @error_messages ||= {
      argument_error: 'We could not export or download this citation because of missing or incorrect data in the parameters. Please use the link below to report this problem.',
      primo_record_error: 'We could not export or download this citation because of missing or incomplete data in the catalog record. Please use the link below to report this problem.',
      too_many_records_error: 'You have requested too many records to be exported/downloaded. Please limit your request to 10 records at a time.',
      not_found_error: "We're sorry! We can't locate that page. It may just be a typo. Double check the resource's spelling and try again.",
      openurl_not_found_error: "We can't find an associated OpenURL for this record. Please use the link below to report this problem."
    }
  end

end
