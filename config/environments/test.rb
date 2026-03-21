require "active_support/core_ext/integer/time"

Rails.application.configure do
  # No need to watch for file changes during a test run.
  config.enable_reloading = false

  # Only load the whole app if running in a CI (Continuous Integration) environment.
  # This keeps local individual tests starting fast.
  config.eager_load = ENV["CI"].present?

  # Show full stack traces so you can debug why a test failed.
  config.consider_all_requests_local = true

  # Disables CSRF protection in tests so you don't have to deal with
  # authenticity tokens when simulating form posts.
  config.action_controller.allow_forgery_protection = false

  # Raise an error if you try to use a callback (like 'before_action')
  # on a controller method that doesn't exist.
  config.action_controller.raise_on_missing_callback_actions = true

  # Completely disables caching so every test starts with a clean slate.
  config.cache_store = :null_store

  # Uses a temporary 'test' storage service so your real uploads aren't affected.
  config.active_storage.service = :test

  # Performance boost for serving images/assets during integration tests.
  config.public_file_server.headers = { "cache-control" => "public, max-age=3600" }

  # Emails aren't actually sent. Instead, they are saved to an array
  # (ActionMailer::Base.deliveries) so you can test if an email *would* have been sent.
  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: "example.com" }

  # Prints warnings about old/deprecated code directly to the terminal.
  config.active_support.deprecation = :stderr

  # Uncomment to ensure every piece of text in your app has a translation.
  # config.i18n.raise_on_missing_translations = true

  # Uncomment to see which HTML partials are being used in your test responses.
  # config.action_view.annotate_rendered_view_with_filenames = true
end
