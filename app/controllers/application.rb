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
			# TODO: here we would load their friends list or whatever.
			@fbuser = user
		end
	end

	# Returns a Date from the params[] passed to this controller (need to be a specific
	# format though: prefix_time_hour, prefix_time_min, prefix_time_ampm, prefix_date_month, prefix_date_day, prefix_date_year
	def date_from_params(prefix)
		hour = params["#{prefix}_time_hour"]
		minute = params["#{prefix}_time_min"]
		# If PM, add 12 hours to hour (makes it military time)
		if params["#{prefix}_time_ampm"] == "pm"
			hour = hour + 12
		end
		month = params["#{prefix}_date_month"]
		day = params["#{prefix}_date_day"]
		year = params["#{prefix}_date_year"]

		if hour.nil? || minute.nil? || month.nil? || day.nil? || year.nil?
			t = Time.new
		else
			t = Time.mktime(year, month, day, hour, minute)
		end
		return t
	end
end
