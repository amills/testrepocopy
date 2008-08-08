# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false
ActionMailer::Base.delivery_method = :sendmail

ActionMailer::Base.sendmail_settings = {
  :location => "/usr/sbin/sendmail",
  :arguments => "-t"
}

#Google_Maps_Api_Key = 'ABQIAAAAwBz7W3z4sedOzgKp8bfXIhQgkZGlVagNg2XBcspSTJffxa0_-xR_JUvw1p9eI5WUVX_JcKXKNjZHoQ'
#Google_Maps_Api_Key = 'ABQIAAAAzplBnsNCqMKpAckyPT4O6BTJun7sl1lcTJa2IewRp5-f_csmPxQbNQPTtIiglTCGR1xU62rSAnODGQ'
Google_Maps_Api_Key = 'ABQIAAAAzplBnsNCqMKpAckyPT4O6BQGQhNz9AdgUrey35zbC9c0uQ-RNhSga2IWViKGJahR0NTGPOBTl18e3w'
