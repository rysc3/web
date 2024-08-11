Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?

  # Add file types to precompile in assets
  precompile_logger = ActiveSupport::Logger.new(STDOUT)
  precompile_logger.formatter = config.log_formatter
  config.assets.logger = precompile_logger

  config.assets.compile = false

  config.assets.precompile += ['*.js', '*.css', '*.jpg', '*.jpeg', '*.png', '*.gif', '*.svg', '*.ico']

  # Enable SSL for secure connections
  # config.force_ssl = true

  config.log_level = :info
  config.log_tags = [ :request_id ]

  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.active_support.disallowed_deprecation = :log
  config.active_support.disallowed_deprecation_warnings = []

  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
