# frozen_string_literal: true

source 'https://rubygems.org'

ruby '>= 3.2.0'

group :development, :test do
  gem 'rake', '~> 13.0'
  gem 'rspec', '~> 3.12'
  gem 'rubocop', '~> 1.57', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', '~> 0.22', require: false
end

group :llm, optional: true do
  gem 'dotenv', '~> 2.8'
  gem 'ruby_llm', '~> 1.9'
end
