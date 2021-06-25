source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").strip

gem "rails", "~> 6.1.3"
gem "mysql2", "~> 0.5.3"
gem "puma", "~> 5.3"
gem "sassc-rails"
gem "sprockets", "~> 4.0.2"
gem "jbuilder", "~> 2.11"
gem "bootsnap", ">= 1.4.2", require: false
gem "tzinfo-data"
gem "devise"
gem "jwt"
gem "omniauth-oauth2"
gem "omniauth-rails_csrf_protection", "~> 0.1"
gem "aws-sdk-s3", "~> 1.96"
gem "ipaddress_2"
gem "aws-sdk-ecs", "~> 1.80"
gem "cancancan", "~> 3.3"
gem "sentry-raven"
gem "audited"
gem "kaminari"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "dotenv-rails"
  gem "rspec-rails", "~> 5.0.1"
  gem "factory_bot_rails"
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", "~> 3.5"
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
  gem "webdrivers"
  gem "webmock"
  gem "rails-controller-testing"
  gem "shoulda-matchers", "~> 4.5"
end
