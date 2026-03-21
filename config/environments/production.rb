require "active_support/core_ext/integer/time"

Rails.application.configure do
  # In production, we don't reload code on every request.
  # This makes the app much faster but means changes require a server restart.
  config.enable_reloading = false

  # Loads the entire app into RAM on boot.
  # This catches syntax errors early and improves performance for users.
  config.eager_load = true

  # Set to false so users don't see raw code or stack traces when things break.
  # Instead, they see the public/500.html page.
  config.consider_all_requests_local = false

  # Tells the browser to cache images/CSS/JS for a long time (1 year)
  # because Rails gives them unique names whenever they change.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Turn on "fragment caching" to speed up view rendering.
  config.action_controller.perform_caching = true
end
