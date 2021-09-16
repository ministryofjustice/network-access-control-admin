source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

gem "audited"
gem "aws-sdk-ecs", "~> 1.84"
gem "aws-sdk-s3", "~> 1.103"
gem "bootsnap", ">= 1.4.2", require: false
gem "cancancan", "~> 3.3"
gem "devise"
gem "ipaddress_2"
gem "kaminari"
gem "mysql2", "~> 0.5.3"
gem "omniauth-oauth2"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "openssl"
gem "puma", "~> 5.4"
gem "rails", "~> 6.1.4"
gem "sassc-rails"
gem "sentry-rails"
gem "sentry-ruby"
gem "sprockets", "~> 4.0.2"
gem "tzinfo-data"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 5.0.2"
  gem "rubocop-govuk", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 5.0"
  gem "webdrivers"
  gem "webmock"
end
