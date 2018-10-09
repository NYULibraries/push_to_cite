require 'sinatra/base'
require 'citero'

class ApplicationController < Sinatra::Base

  set :show_exceptions, false
  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  @@whitelisted_calling_systems = %w(primo)

  get('/:local_id') do
    @institution, @local_id, @cite_to = params[:institution], params[:local_id], push_format(params[:cite_to])
    @calling_system = params[:calling_system] if @@whitelisted_calling_systems.include?(params[:calling_system])

    unless missing_params? || primo.error?
      # Map the citation and then decide what the course of acion is
      @csf = Citero.map(primo.get_pnx_json).from_pnx_json.send("to_#{@cite_to.to_format}".to_sym)
      push_to_or_download
    else
      status 400
      erb :error
    end
  end

  error StandardError do
    status 400
    erb :error
  end

  # Should we push to an external citation system or download the file?
  def push_to_or_download
    @cite_to.download? ? download : push_to_external
  end

 private

  # Downloads a file with the citation
  def download
    content_type @cite_to.mimetype
    attachment(@cite_to.filename)
    @csf.force_encoding('UTF-8')
  end

  # Push to external system either by redirecting with a callback url which
  # sends the external system back to push_to_cite
  # Or render the form and post with Javascript, depending on how the
  # external system API expects it
  def push_to_external
    if !params.has_key?(:callback) && @cite_to.redirect_to_external?
      redirect @cite_to.action + callback, 303
    elsif @cite_to.redirect_to_data?
      redirect PushFormats::Openurl.link_resolver_base_url + @csf, 303
    else
      erb :post_form
    end
  end

  # Whitelist available formats and forward to relevant classes
  def push_format(cite_to)
    case cite_to.to_sym
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
      else raise ArgumentError
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

end
