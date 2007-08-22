# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

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

	# Initialize Facebook User - Creates a User if needed, maps friends, etc. Use as a
	# before_filter.
	def initialize_facebook_user
		if fbsession && fbsession.is_valid?
			user = User.find_or_create_by_facebook_session(fbsession)

		end
	end
end
