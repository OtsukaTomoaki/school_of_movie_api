source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4"

# Use mysql as the database for Active Record
gem "mysql2", "~> 0.5"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
gem "redis", "~> 4.0"

gem 'redis-rails'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem "rack-cors"

gem 'dotenv'

gem "dotenv-rails"

gem 'bcrypt'

gem 'jbuilder'

gem "aws-sdk-s3", require: false

gem 'jwt'

gem 'omniauth'

gem 'omniauth-google-oauth2'

gem 'omniauth-rails_csrf_protection'

gem 'httpclient'

gem 'json'

gem 'base64'

gem 'uri'

gem 'whenever', require: false

gem 'natto'

gem 'rest-client'

gem 'activerecord-import'

gem 'sanitize'

gem 'kaminari'

gem 'sidekiq'

gem 'aws-sdk-secretsmanager'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  gem 'factory_bot_rails'

  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'solargraph', require: false
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  gem 'capybara'
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'action-cable-testing'
  gem 'webmock'
  gem 'shoulda-matchers'
  gem 'rails-controller-testing'
  gem 'timecop'
end