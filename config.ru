# Rackup file for RestlessNapkin.

# Require basic Rails stuff.
require "config/environment"

# Set up MacroDeck-App
$LOAD_PATH << File.join(Rails.root, "lib", "macrodeck-app", "lib")
require "macrodeck-app"
require "macrodeck-config"
require "macrodeck-behavior"
require "behaviors/abbreviation_behavior"
require "behaviors/address_behavior"
require "behaviors/description_behavior"
require "behaviors/fare_behavior"
require "behaviors/geo_behavior"
require "behaviors/phone_number_behavior"
require "behaviors/title_behavior"
require "behaviors/url_behavior"

# Load MacroDeck configuration.
cfg = MacroDeck::Config.new(File.join(Rails.root, "config", "macrodeck.yml"))

# Map stuff with Rack
use Rails::Rack::LogTailer

map "/" do
	use Rails::Rack::Static
	run ActionController::Dispatcher.new
end

map cfg.path_prefix do
	MacroDeck::App.configuration = cfg
	MacroDeck::App.set :views, File.join(Rails.root, cfg.view_dir)
	MacroDeck::App.set :public, File.join(Rails.root, "public")

	run MacroDeck::App
end

# vim:set ft=ruby
