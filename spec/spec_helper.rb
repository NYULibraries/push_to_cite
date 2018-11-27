require 'coveralls'
Coveralls.wear!
require 'rack/test'
require 'rspec'
require 'pry'
require 'rspec/its'

ENV['RACK_ENV'] = 'test'

Dir.glob('./app/**/*.rb').each { |file| require file }
Dir.glob('./spec/support/**/*.rb').each { |file| require file }

module RSpecMixin
  include Rack::Test::Methods
end

RSpec.configure do |config|
  config.include RSpecMixin
end

require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { record: :new_episodes }
  # c.allow_http_connections_when_no_cassette = true
end
