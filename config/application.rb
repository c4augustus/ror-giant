require File.expand_path('../boot', __FILE__)

## customized to use mongoid [2014.02.13 cathames]
##require 'rails/all'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module RorGiant
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.action_mailer.default_url_options = {
      host: 'giantrecruiting.com'
    }

    config.custom_email_address_for_resumes =
      # development testing:
      ##'resumes@christopheraugustus.com'
      # until forwarding can be set up:
      ##'resumes@giantrecruiting.com'
      'resumes@giant-staffing.com'

    config.smtp_settings = {
      # development testing:
=begin
      address:              'mail.worldfusion.com',
      domain:               'worldfusion.com',
      port:                 465,
      ssl:                  true,
      tls:                  true,
      enable_starttls_auto: false,
      openssl_verify_mode:  :none,
      authentication:       :login,
      user_name:            ENV['RAILS_SMTP_SETTINGS_USER_NAME'],
      password:             ENV['RAILS_SMTP_SETTINGS_PASSWORD'],
=end
      address: 'mail.giantrecruiting.com'
    }

    def jobs_facility
      @jobs_facility ||= JobsFacility.new
    end
  end
end
