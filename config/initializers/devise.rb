# frozen_string_literal: true

Devise.setup do |config|
  # ==> Mailer Configuration
  config.mailer_sender = "support@yourdomain.com"
  # config.mailer = 'Devise::Mailer'

  # ==> ORM Configuration
  require "devise/orm/active_record"

  # ==> Authentication Keys
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [ :http_auth ]

  # ==> Database Authenticatable (Bcrypt)
  # Cost is 1 for tests (speed) and 12 for production (security)
  config.stretches = Rails.env.test? ? 1 : 12
  # config.pepper = 'your_secret_pepper'

  # ==> Confirmable
  config.reconfirmable = true
  # config.confirm_within = 3.days

  # ==> Rememberable
  config.expire_all_remember_me_on_sign_out = true
  # config.remember_for = 2.weeks

  # ==> Validatable
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Recoverable
  config.reset_password_within = 6.hours

  # ==> Navigation & Sign Out
  config.sign_out_via = :delete

  # ==> Hotwire / Turbo Integration
  config.responder.error_status = :unprocessable_content
  config.responder.redirect_status = :see_other

  config.navigational_formats = [ "*/*", :html, :turbo_stream ]

  # ==> OmniAuth
  # config.omniauth :github, 'APP_ID', 'APP_SECRET', scope: 'user'
end
