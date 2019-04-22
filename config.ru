# config.ru
require 'rack'
require 'sinatra/base'
require_relative 'config/metrics'
require 'raven'

require 'ddtrace'

Datadog.configure do |c|
  c.use :sinatra, service_name: 'PushToCite'
  c.tracer enabled: ((ENV['RACK_ENV'] == 'production') ? true : false), 
           env: ENV['RACK_ENV'],
           tags: { 'env' => ENV['RACK_ENV'], 'app' => 'pushtocite', 'framework' => 'sinatra' }
end

# pull in the helpers and controllers
Dir.glob('./app/{helpers,controllers,lib}/**/*.rb').each { |file| require file }

Raven.configure do |config|
  config.server = ENV['SENTRY_DSN']
end

# Run sentry
use Raven::Rack
use Rack::Deflater
# Run prometheus middleware to collect default metrics
use Prometheus::Middleware::CollectorWithExclusions
# Run prometheus exporter to have a /metrics endpoint that can be scraped
# The endpoint will only be available to prometheus
use Prometheus::Middleware::Exporter

run ApplicationController
