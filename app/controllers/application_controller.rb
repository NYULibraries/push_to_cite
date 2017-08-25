require 'sinatra/base'

class ApplicationController < Sinatra::Base
  enable :sessions

  set :root, File.expand_path('../..', __FILE__)
  set :public_folder, File.expand_path('../../../public', __FILE__)

  get('/') do
    print "Hello"
  end

end
