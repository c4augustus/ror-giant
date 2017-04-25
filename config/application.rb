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

    config.custom_email_domain_default =
      # development testing:
      #'c4augustus.com'
      'giantrecruiting.com'
    config.custom_email_address_for_resumes =
      # development testing:
      #"support@#{config.custom_email_domain_default}"
      "resumes@#{config.custom_email_domain_default}"
    config.custom_link_facebook =
      "https://www.facebook.com/pages/Giant-Staffing-LLC/522568731137415"
    config.custom_link_linkedin =
      "https://www.linkedin.com/company/giant-staffing"
    config.custom_link_twitter =
      "https://twitter.com/GiantStaffing"

    config.action_mailer.default_url_options = {
      host: config.custom_email_domain_default
    }
    config.action_mailer.smtp_settings = {
      #address:              'secure.emailsrvr.com',
      address:              'smtp.emailsrvr.com',
      domain:               config.custom_email_domain_default,
      #port:                 465,
      port:                 587,
      #ssl:                  true,
      ssl:                  false,
      #tls:                  true,
      tls:                  false,
      #enable_starttls_auto: true,
      enable_starttls_auto: false,
      #openssl_verify_mode:  :none,
      #authentication:       :login,
      authentication:       :plain,
      user_name:            Rails.application.secrets[:service_external_smtp]['account_user_name'],
      password:             Rails.application.secrets[:service_external_smtp]['account_password']
      #user_name:            ENV['RAILS_SMTP_SETTINGS_USER_NAME'],
      #password:             ENV['RAILS_SMTP_SETTINGS_PASSWORD'],
    }

    def jobs_facility
      @jobs_facility ||= JobsFacility.new
    end
  end
end
