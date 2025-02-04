source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

gem "audited", "5.7.0"
gem "aws-sdk-ecs", "~> 1.165.0"
gem "aws-sdk-s3", "~> 1.132"
gem "cancancan", "~> 3.5"
gem "delayed_job_active_record", "4.1.7"
gem "devise"
gem "ip", "~> 0.3.1"
gem "ipaddress_2"
gem "kaminari"
gem "mysql2", "~> 0.5.5"
gem "omniauth-oauth2"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "openssl"
gem "puma", "~> 6.4"
gem "rails", "7.2.1.1"
gem "ransack"
gem "sassc-rails", "~> 2.1.0"
gem "sentry-rails"
gem "sentry-ruby"
gem "sprockets", "~> 4.2.1"
gem "tzinfo-data"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 7.0.0"
  gem "rubocop-govuk", require: false
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 5.3"
  gem "timecop"
  gem "webdrivers"
  gem "webmock"
end
