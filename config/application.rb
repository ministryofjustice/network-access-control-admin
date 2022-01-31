require_relative "boot"

require "rails"
# Pick the frameworks you want:
# see https://guides.rubyonrails.org/initialization.html
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "action_mailbox/engine"
require "action_text/engine"
# require "rails/test_unit/railtie"
require "sprockets/railtie"
require "audited/audit"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NetworkAccessControlAdmin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.active_record.legacy_connection_handling = false

    # Force HTTPS for all requests except healthcheck endpoint
    config.force_ssl = true
    config.ssl_options = {
      redirect: {
        exclude: ->(request) { request.path =~ /healthcheck/ },
      },
    }
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # https://github.com/alphagov/govuk-frontend/issues/1350
    config.assets.css_compressor = nil
    config.active_job.queue_adapter = :delayed_job

    config.generators do |g|
      g.test_framework :rspec
      g.integration_tool :rspec
    end
  end
end
