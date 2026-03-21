require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module ELogPulse
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    # Only keep config you are actually using:
    # config.time_zone = "UTC"
  end
end
