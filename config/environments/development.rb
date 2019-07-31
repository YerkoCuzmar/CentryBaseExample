Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.



  /---------------CONFIGURATION---------------/
  #CENTRY CONFIGURATION
  ENV["CENTRY_CLIENT_ID"]     = "bb523e77b31b8092e7aae3b2f495a4b31031e5dea9130b3ac9c18904f150e87a"
  ENV["CENTRY_SECRET"]        = "45418afdadf07a6a9b8f2bbcbeda7b9c4fc29cdc8ca3b069d5657d6c830bc08f"
  ENV["CENTRY_REDIRECT_URI"]  = "urn:ietf:wg:oauth:2.0:oob"
  ENV["CENTRY_SCOPE"]         = "public read_orders write_orders read_products write_products read_integration_config write_integration_config read_user write_user read_webhook write_webhook"
  ENV["BASE_URL"]             = "https://83e4633e.ngrok.io"
  #YOUR INTEGRATION CONFIGURATION
  ENV["HOST"]     = "http://127.0.1.1/magento"
  ENV["USERNAME"] = "admin"
  ENV["PASSWORD"] = "admin234"
  ENV["UPDATE_NULL_STOCK"]      = "false"
  ENV["UPDATE_WITH_MAX_PRICE"]  = "false"
  ENV["STOCK_UPDATE_INTERVAL"]  = "* * * * *" #unix crontab notation https://crontab.guru/examples.html
  ENV["PRICE_UPDATE_INTERVAL"]  = "* * * * *"
  /------------------------------------------/



  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # rou
  # tes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker


end
