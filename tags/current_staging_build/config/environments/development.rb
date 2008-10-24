# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
#config.action_view.cache_template_extensions         = false
config.action_view.debug_rjs                         = true

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# For console logging during development
ActiveRecord::Base.logger = Logger.new(STDOUT)

# For Slicehost dev accounts
ActionMailer::Base.delivery_method = :sendmail

ActionMailer::Base.sendmail_settings = {
  :location => "/usr/sbin/sendmail",
  :arguments => "-t"
}

Google_Maps_Api_Key = 'ABQIAAAAb5FIzoTRib2_GSmlbkQ7mBSmj5SEivQATyWojPmDElbJWyb8ZxQu0yMBdlNrfGjnOEwcmui2dVSyJQ'