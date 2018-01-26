require 'sinatra/base'
require 'citero'
class ApplicationController < Sinatra::Base

  set :show_exceptions, false
  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  @@whitelisted_calling_systems = %w(primo)

  get('/') do
    @institution, @local_id, @cite_to = params[:institution], params[:local_id], push_format(params[:cite_to])
    @calling_system = params[:calling_system] if @@whitelisted_calling_systems.include?(params[:calling_system])

    unless missing_params?
      # require 'pry'; binding.pry
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

  def push_format(cite_to)
    case cite_to.to_sym
      when :endnote
        PushFormats::Endnote.new
      when :refworks
        PushFormats::Refworks.new
      when :easybib
        PushFormats::Easybib.new
      when :ris
        PushFormats::Ris.new
      when :bibtex
        PushFormats::Bibtex.new
      else raise ArgumentError
    end
  end

  def push_to_or_download
    @cite_to.push_to_external ? push_to_external : download
  end

  # Downloads a file with citation
  def download
    content_type @cite_to.mimetype
    attachment(@cite_to.filename)
    @csf.force_encoding('UTF-8')
  end

  def push_to_external
    # require 'pry';binding.pry
    if !params.has_key?(:callback) && @cite_to.redirect
      redirect @cite_to.action + callback, 303
    else
      erb :post_form
    end
  end

  def callback
    @callback ||= ERB::Util.url_encode("#{request.url}&callback")
  end

  def missing_params?
    !(@institution && @local_id && @cite_to && @calling_system)
  end

  def primo
    @primo ||= CallingSystems::Primo.new(@local_id, @institution)
  end

end
