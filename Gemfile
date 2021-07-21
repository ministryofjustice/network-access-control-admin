source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

gem "audited"
gem "aws-sdk-ecs", "~> 1.81"
gem "aws-sdk-s3", "~> 1.96"
gem "bootsnap", ">= 1.4.2", require: false
gem "cancancan", "~> 3.3"
gem "devise"
gem "ipaddress_2"
gem "jbuilder", "~> 2.11"
gem "jwt"
gem "kaminari"
gem "mysql2", "~> 0.5.3"
gem "omniauth-oauth2"
gem "omniauth-rails_csrf_protection", "~> 1.0"
gem "openssl"
gem "puma", "~> 5.3"
gem "rails", "~> 6.1.4"
gem "rails-erd"
gem "rubocop-govuk", require: false
gem "sassc-rails"
gem "sentry-raven"
gem "sprockets", "~> 4.0.2"
gem "tzinfo-data"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: %i[mri mingw x64_mingw]
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "rspec-rails", "~> 5.0.1"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "listen", "~> 3.6"
  gem "web-console", ">= 3.3.0"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"

  gem "standardrb"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "simplecov-console", require: false
  # Easy installation and use of web drivers to run system tests with browsers
  gem "rails-controller-testing"
  gem "shoulda-matchers", "~> 5.0"
  gem "webdrivers"
  gem "webmock"
end
