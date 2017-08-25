# config.ru
require 'sinatra/base'

# pull in the helpers and controllers
Dir.glob('./app/{helpers,controllers}/*.rb').each { |file| require file }

run ApplicationController
