# config.ru
require 'sinatra/base'
require 'prometheus/middleware/collector'
require 'prometheus/middleware/exporter'
require 'raven'

# pull in the helpers and controllers
Dir.glob('./app/{helpers,controllers,lib}/**/*.rb').each { |file| require file }

Raven.configure do |config|
  config.server = ENV['SENTRY_DSN']
end

# Run sentry
use Raven::Rack
# Run prometheus
use Prometheus::Middleware::Collector
use Prometheus::Middleware::Exporter

run ApplicationController
