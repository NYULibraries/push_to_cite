require 'sinatra/base'
require 'citero'
require 'pry'

class ApplicationController < Sinatra::Base
  class PrimoRecordError < ArgumentError; end
  class TooManyRecordsError < ArgumentError; end
  class InvalidExportTypeError < ArgumentError; end

  set :show_exceptions, false
  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  before do
    # Skip setting the instance vars if it's just the healthcheck
    pass if %w[healthcheck batch].include?(request.path_info.split('/')[1]) || request.path_info == '/'
    @local_id = (params[:local_id] || request.path_info.split('/').last)
    set_vars_from_params
    raise ArgumentError, 'Missing required params. All params required: local_id, institution, cite_to, calling_system' if missing_params? || !@local_id
    raise PrimoRecordError, "Could not find Primo record with id: #{@local_id}" if primo.error?
  end

  before do
    pass unless %w[batch].include?(request.path_info.split('/')[1])
    @local_id = params[:local_ids]
    set_vars_from_params
    raise ArgumentError, 'Missing required params. All params required: local_ids, institution, cite_to, calling_system' if missing_params? || !@local_id
    raise InvalidExportTypeError, "Could not batch export to type: #{@cite_to}" unless whitelisted_batch_formats.include?(params[:cite_to])
  end

  # Healthcheck
  get('/healthcheck') do
    content_type :json
    return { success: true }.to_json
  end

  # Citation Data Viewer
  get('/m/:local_id') do
    erb :data_viewer, locals: { csf: csf_string, primo_api_url: primo.pnx_json_api_endpoint }
  end

  get('/openurl/:local_id') do
    pass unless request.accept? 'application/json'
    content_type :json
    return { openurl: primo.openurl }.to_json
  end

  # Main route
  get('/:local_id') do
    if params[:cite_to] === 'json'
      pass unless request.accept? 'application/json'
      content_type :json
      return csf_object.to_json
    else
      download_or_push
    end
  end

  post('/batch') do
    raise TooManyRecordsError, 'Too many records: You can only export up to ten records.' if @local_id.count > 10
    @records = gather_citero_records
    download_or_push
  end

  error ArgumentError do
    status 400
    erb :error, locals: { local_ids: display_local_ids, msg: error_msgs[:argument_error] }
  end

  error PrimoRecordError do
    status 422
    erb :error, locals: { local_ids: display_local_ids, msg: error_msgs[:primo_record_error] }
  end

  error InvalidExportTypeError do
    status 400
    erb :error, locals: { local_ids: display_local_ids, msg: error_msgs[:invalid_export_type_error] }
  end

  error TooManyRecordsError do
    status 400
    erb :error, locals: { local_ids: display_local_ids, msg: error_msgs[:too_many_records_error] }
  end

  not_found do
    status 404
    erb :error, locals: { local_ids: display_local_ids, msg: error_msgs[:not_found_error] }
  end

  error 500 do
    status 500
    erb :error
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
    csf_string.force_encoding('UTF-8')
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
      erb :post_form, locals: { csf: csf_string }
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
        {}
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
    !(@institution && @cite_to && @calling_system)
  end

  def set_vars_from_params
    @institution, @cite_to = params[:institution], push_format(params[:cite_to])
    @calling_system = params[:calling_system] if whitelisted_calling_systems.include?(params[:calling_system])
  end

  def whitelisted_batch_formats
    @whitelisted_batch_formats ||= [:bibtex, :ris, :refworks, :endnote].map(&:to_s)
  end

  # Make a call to Primo to get the PNX record
  def primo(id = @local_id, institution = @institution)
    CallingSystems::Primo.new(id, institution)
  end

  def display_local_ids
    @local_id
  end

  def gather_citero_records(records = [])
    [@local_id].flatten.each do |id|
      record = primo(id)
      records << citero(record).send("to_#{@cite_to.to_format}".to_sym)
    end
    records
  end

  def csf_string
    [gather_citero_records].flatten.join("\n")
  end

  def csf_object
    citero.csf.csf
  end

  def citero(primo_object)
    Citero.map(primo_object.get_pnx_json).from_pnx_json
  end

  def whitelisted_calling_systems
    @whitelisted_calling_systems ||= %w(primo)
  end

  def error_msgs
    @error_msgs ||= {
      argument_error: 'We could not export or download this citation because of missing data in the parameters. Please use the link below to report this problem.',
      primo_record_error: 'We could not export or download this citation because of missing or incomplete data in the catalog record. Please use the link below to report this problem.',
      invalid_export_type_error: 'You have requested an invalid export type. Please limit your request to one of the following cite_to values: ' + whitelisted_batch_formats.join(", "),
      too_many_records_error: 'You have requested too many records to be exported/downloaded. Please limit your request to 10 records at a time.',
      not_found_error: "We're sorry! We can't locate that page. It may just be a typo. Double check the resource's spelling and try again."
    }
  end

end
