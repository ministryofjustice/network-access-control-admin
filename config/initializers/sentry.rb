if ENV.fetch("RAILS_ENV") == "production"
  Sentry.init do |config|
    config.dsn = ENV.fetch("SENTRY_DSN")
    config.breadcrumbs_logger = %i[active_support_logger sentry_logger]
  end
end
