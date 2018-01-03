source 'https://rubygems.org'

gem 'rake'
gem 'sinatra'
gem 'unicorn'
gem 'json'
gem 'rest-client'
# gem 'citero', github: 'NYULibraries/citero', branch: 'bug/pnx_json'
gem 'citero', path: '/apps/citero'

group :test do
  gem 'rspec', '~> 3'
  gem 'rspec-its', '~> 1.2'
  gem 'rack-test', require: 'rack/test'
  gem 'vcr', '~> 3'
  gem 'webmock', '~> 3'
end

group :test, :development do
  gem 'pry'
end

ruby '2.4.3'
