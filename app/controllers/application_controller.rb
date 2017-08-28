require 'sinatra/base'
require_relative '../lib/calling_systems/primo'
require_relative '../lib/export_citations'
require 'pry'
require_relative '../../lib/pnx_json'

class ApplicationController < Sinatra::Base

  set :show_exceptions, false
  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  @@whitelisted_calling_systems = %w(primo)

  get('/') do
    @institution, @local_id, @cite_to = params[:institution], params[:local_id], params[:cite_to]
    @calling_system = params[:calling_system] if @@whitelisted_calling_systems.include?(params[:calling_system])

    unless missing_params?
      @csf = PnxJson.new(get_primo_parsed).to_csf
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

  def missing_params?
    !(@institution && @local_id && @cite_to && @calling_system)
  end

  def redirect_link
    @redirect_link ||= export_citations.redirect_link
  end

  def export_citations_url
    @export_citations_url ||= ExportCitations.export_citations_url
  end

  def export_citations
    @export_citations ||= ExportCitations.new(primo.get_openurl, @cite_to)
  end

  def primo
    @primo ||= CallingSystems::Primo.new(@local_id, @institution)
  end

end
