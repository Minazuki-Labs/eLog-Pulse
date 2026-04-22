require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module ELogPulse
  class Application < Rails::Application
    config.load_defaults 8.1

    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "Kuala Lumpur"
    config.active_record.default_timezone = :utc
  end
end
