require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Allows you to see code changes immediately without restarting the server.
  config.enable_reloading = true

  # Set to false so Rails doesn't load the whole app on startup. 
  # This makes the server start faster in development.
  config.eager_load = false

  # Provides the "Interactive Debugger" page (Web Console) when an error occurs.
  config.consider_all_requests_local = true

  # Adds performance headers to the response so you can track speed in browser dev tools.
  config.server_timing = true

  # Shows a helpful error page if you forgot to run 'rails db:migrate'.
  config.active_record.migration_error = :page_load

  # Toggle caching by running: rails dev:cache
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.public_file_server.headers = { "cache-control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
  end

  # Stores cache in RAM. Change to :null_store if you want to disable caching entirely.
  config.cache_store = :memory_store

  # Files uploaded via ActiveStorage will be saved in the /storage folder locally.
  config.active_storage.service = :local

  # Prevents your app from crashing if an email fails to send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_caching = false
  
  # Required for generating links in emails (e.g., password resets).
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Prints warnings about deprecated Rails features to the terminal/log file.
  config.active_support.deprecation = :log

  # Tells you exactly which line of code triggered a Database query or Background job.
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true
  
  # Adds SQL comments to your logs to help track where queries come from.
  config.active_record.query_log_tags_enabled = true

  # Keeps the logs clean by not showing every request for images/CSS/JS files.
  config.assets.quiet = true

  # Adds HTML comments to your browser's "Inspect Element" showing which partial rendered the HTML.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Raises an error if you try to use a callback (like 'before_action') on a method that doesn't exist.
  config.action_controller.raise_on_missing_callback_actions = true
end
