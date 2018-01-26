require 'sinatra/base'
require_relative '../lib/calling_systems/primo'
require_relative '../lib/pnx_json'
require 'citero'
require_relative '../lib/push_formats/base'
require_relative '../lib/push_formats/endnote'

class ApplicationController < Sinatra::Base

  set :show_exceptions, false
  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  @@whitelisted_calling_systems = %w(primo)

  get('/') do
    @institution, @local_id, @cite_to = params[:institution], params[:local_id], push_format(params[:cite_to])
    @calling_system = params[:calling_system] if @@whitelisted_calling_systems.include?(params[:calling_system])

    unless missing_params?
      # @csf = PnxJson.new(primo.get_pnx_json).to_csf
      # @csf = Citero::Inputs::PnxJson.new(primo.get_pnx_json).csf
      @csf = Citero.map(primo.get_pnx_json).from_pnx_json.to_ris
      erb :post_form
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
      when :easybib
      when :ris
      when :bibtex
      else raise ArgumentError
    end
  end

  def missing_params?
    !(@institution && @local_id && @cite_to && @calling_system)
  end

  def export_citations_url
    ENV['EXPORT_CITATIONS_URL'] || "http://web1.bobst.nyu.edu/export_citations/export_citations"
  end

  def primo
    @primo ||= CallingSystems::Primo.new(@local_id, @institution)
  end

end
