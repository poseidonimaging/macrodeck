# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# FIXME: Since RFacebook 0.8.0, all of this stuff here is no longer needed, and in fact
# *BREAKS* the application! Waiting for RubyGems to update their database so I can get on
# with life.

require "facebook_rails_controller_extensions"

class ApplicationController < ActionController::Base
	
	include RFacebook::RailsControllerExtensions

	def facebook_api_key
		"d90f27cab1014065a8c90630186b9776"
	end

	def facebook_api_secret
		"8564bcd16141d4c650dd4dc55725b291"
	end

	def finish_facebook_login
		redirect_to "http://places.macrodeck.com/facebook/"
	end

	# Is the e-mail address specified a valid address?
	def email_valid?(email)
		if email =~ EMAIL_VALIDATION
			return true
		else
			return false
		end
	end
	
	# Set no cache headers
	def do_not_cache
		@headers["Expires"] = "Thu, 01 Jan 1970 01:00:00 GMT"
		@headers["Last-Modified"] = Time.now.strftime("%a, %d %b %Y %H:%M:%S") + " GMT"
		@headers["Cache-Control"] = "no-cache, must-revalidate"
		@headers["Pragma"] = "no-cache"
	end
end
