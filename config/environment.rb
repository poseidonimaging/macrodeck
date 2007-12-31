# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way

ENV['RAILS_ENV'] ||= 'development'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.6'

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

# Constants for UUIDs
# This moved to services/lib/local_uuids.rb.
# FIXME: See if we still need these! If not, remove them from here.
USER_CSAKON       = "9add1be8-a635-49d7-aa0f-91b6638e9dd0"
USER_ZIGGYTHEHAMSTER  = "c4a038aa-372a-4f5c-81b7-351660f7049b"
GROUP_MACRODECK     = "253d41a1-8b62-4ca8-9f8d-99bb42bc0dd8"
BLOG_MACRODECK      = "9a9fc352-89d4-4b92-a94b-45a8cac106bb"
CREATOR_MACRODECK   = "7b7e7c62-0a56-4785-93d5-6e689c9793c9"

# E-mail validation regex
#EMAIL_VALIDATION   = /^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/
EMAIL_VALIDATION    = /^([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|"([\x00-\x0C\x0E-\x21\x23-\x5B\x5D-\x7F]|\\[\x00-\x7F])*")(\.([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|"([\x00-x0C\x0E-\x21\x23-\x5B\x5D-\x7F]|\\[\x00-\x7F])*"))*@([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|\[([\x00-\x0C\x0E-\x5A\x5E-\x7F]|\\[\x00-\x7F])*\])(\.([a-zA-Z0-9&_?\/`!|#*$^%=~{}+'-]+|\[([\x00-\x0C\x0E-\x5A\x5E-\x7F]|\\[\x00-\x7F])*\]))*$/
PHONE_VALIDATION	= /^[01]?[- .]?(\([2-9]\d{2}\)|[2-9]\d{2})[- .]?\d{3}[- .]?\d{4}$/

# User Password Salt
PASSWORD_SALT   = "giomullyoxonoind" # Random character generator

# Places
PLACES_BASEURL = "http://places.intranet.ignition-project.com:3000" # do not use a trailing slash
PLACES_FBURL = "http://apps.facebook.com/macrodeckplaces" # do not use a trailing slash
FLICKR_API_KEY = "686693e936d2bd4bfc3c5477fa3f1332"
FLICKR_SECRET = "b9a60cf2f27ed59c"

# Start services we need
Services.startService "uuid_service"
Services.startService "data_service"
Services.startService "blog_service"
Services.startService "user_service"
Services.startService "places_service"
Services.startService "comment_service"

# Start web services now
Services.startService "data_web_service"

require 'flickr'
require 'flickr_extensions'
require 'acts_as_ferret'
