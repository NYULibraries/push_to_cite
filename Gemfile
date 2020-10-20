source 'https://rubygems.org'

gem 'rake', '~> 12.3.3'
gem 'sinatra', '~> 2.0.3'
gem 'unicorn', '~> 5.3.0'
gem 'json', '~> 2.3.1'
gem 'rest-client', '~> 2.0.2'
gem 'citero', github: 'NYULibraries/citero', tag: 'v1.0.2'

group :test do
  gem 'rspec', '~> 3'
  gem 'rspec-its', '~> 1.2'
  gem 'rack-test', require: 'rack/test'
  gem 'vcr', '~> 3'
  gem 'webmock', '~> 3'
  gem 'coveralls', require: false
  gem 'rspec_junit_formatter', '~> 0.4.1'
end

group :test, :development do
  gem 'pry', '~> 0.10.4'
  gem 'rubocop', require: false
  gem 'rerun', '~> 0.13.0'
end

gem 'sentry-raven', '~> 2'
# gem 'ddtrace', '~> 0.21.1'
gem 'prometheus-client', '~> 2.0.0'
