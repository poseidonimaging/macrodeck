# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way

#ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

# A list of months!
MONTHS_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"] 

# E-mail validation regex
#EMAIL_VALIDATION   = /^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/
EMAIL_VALIDATION    = /^([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|"([\x00-\x0C\x0E-\x21\x23-\x5B\x5D-\x7F]|\\[\x00-\x7F])*")(\.([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|"([\x00-x0C\x0E-\x21\x23-\x5B\x5D-\x7F]|\\[\x00-\x7F])*"))*@([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|\[([\x00-\x0C\x0E-\x5A\x5E-\x7F]|\\[\x00-\x7F])*\])(\.([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|\[([\x00-\x0C\x0E-\x5A\x5E-\x7F]|\\[\x00-\x7F])*\]))*$/
PHONE_VALIDATION	= /^[01]?[- .]?(\([2-9]\d{2}\)|[2-9]\d{2})[- .]?\d{3}[- .]?\d{4}$/

# User Password Salt
PASSWORD_SALT   = "giomullyoxonoind" # Random character generator

# Places
PLACES_TEST_SERVER = false

if PLACES_TEST_SERVER
	PLACES_BASEURL = "http://places.intranet.ignition-project.com" # do not use a trailing slash
	PLACES_FBURL = "http://apps.facebook.com/macrodeckplaces-test" # do not use a trailing slash
	PLACES_APPURL = "http://www.facebook.com/apps/application.php?id=6592864647"
	FLICKR_API_KEY = "686693e936d2bd4bfc3c5477fa3f1332"
	FLICKR_SECRET = "b9a60cf2f27ed59c"
	ENV['RAILS_ENV'] ||= 'development'
	ActionController::Base.asset_host = PLACES_BASEURL
	puts "*** Using Test Server!"
else
	PLACES_BASEURL = "http://places.macrodeck.com" # do not use a trailing slash
	PLACES_FBURL = "http://apps.facebook.com/macrodeckplaces" # do not use a trailing slash
	PLACES_APPURL = "http://www.facebook.com/apps/application.php?id=2475497610"
	FLICKR_API_KEY = "686693e936d2bd4bfc3c5477fa3f1332"
	FLICKR_SECRET = "b9a60cf2f27ed59c"
end

# Start services we need
Services.startService "uuid_service"
Services.startService "data_service"
Services.startService "user_service"
Services.startService "comment_service"
Services.startService "event_service"
Services.startService "places_service"
Services.startService "navigation_service"

# Start web services now
Services.startService "data_web_service"

require 'flickr'
require 'flickr_extensions'
require 'string_extension'
require 'acts_as_ferret'
