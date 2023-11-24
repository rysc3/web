require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Uncomment the line below if you're using Rails credentials or encrypted files
  # config.require_master_key = true

  # Serve static files from the /public folder (set by default)
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

  # Use a different cache store if necessary (default is :null_store)
  # config.cache_store = :mem_cache_store

  # Set up a queue adapter for Active Job (if used)
  # config.active_job.queue_adapter = :resque
  # config.active_job.queue_name_prefix = "web_production"

  # Set to true for immediate email delivery errors (if using Action Mailer)
  # config.action_mailer.raise_delivery_errors = true

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

  # Configure database switching middleware if needed
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

  # Configure Action Cable settings if used
  # config.action_cable.mount_path = nil
  # config.action_cable.url = 'wss://example.com/cable'
  # config.action_cable.allowed_request_origins = [ 'http://example.com', /http:\/\/example.*/ ]
end
