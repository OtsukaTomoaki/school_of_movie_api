require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  # if Rails.root.join("tmp/caching-dev.txt").exist?
  #   config.public_file_server.headers = {
  #     "Cache-Control" => "public, max-age=#{2.days.to_i}"
  #   }
  # else
  #   config.action_controller.perform_caching = false

  #   config.cache_store = :null_store
  # end
  cache_url = ENV['CACHE_URL'].present? ? ENV['CACHE_URL'] : "redis://redis:6379/0/cache"
  config.cache_store = :redis_store, cache_url, { expires_in: 5.minutes }

  config.active_record.cache_versioning = false

  # Store uploaded files on the local file system (see config/storage.yml for options).
  if ENV['STORAGE_SERVICE'].present?
    config.active_storage.service = ENV['STORAGE_SERVICE'].to_sym
  else
    config.active_storage.service = :local
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  config.action_cable.disable_request_forgery_protection = true
  config.action_cable.allowed_request_origins = [ ENV['ROOT_URL'] ]
  config.action_cable.url = "wss://#{ENV['DOMAIN']}/cable"
  config.hosts << ENV['DOMAIN']
end
