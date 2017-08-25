require 'sinatra/base'
require 'rest-client'
require 'pry'

class ApplicationController < Sinatra::Base

  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  get('/') do
    @institution = params[:institution]
    @calling_system = params[:calling_system]
    @local_id = params[:local_id]
    @cite_to = params[:cite_to]
    redirect redirect_link
  end

  def redirect_link
    "http://web1.bobst.nyu.edu/export_citations/export_citations?to_format=#{@cite_to}&#{URI.parse(get_primo_link).query}"
  end

  def get_primo_link(link_field = "lln10")
    @get_primo_link ||= get_primo_parsed["delivery"]["link"].select {|el| el["displayLabel"] == link_field}.first["linkURL"]
  end

  def get_primo_parsed
    @get_primo_parsed ||= JSON.parse(get_primo_record.body)
  end

  def get_primo_record
    @get_primo_record ||= RestClient.get("http://bobcatdev.library.nyu.edu/primo_library/libweb/webservices/rest/v1/pnxs/L/#{@local_id}", {params: {inst: @institution}})
  end

end
