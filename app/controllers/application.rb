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

    # A URL helper that will hopefully override the default fbplaces_url and let you
    # link to crap easier.
    #
    # options_hash possible values:
    #   :action => (any action you wish... used in ../action/us/ok/tulsa/
    #   :country => (two-letter country code)
    #   :state => (two-letter state)
    #   :city => City object
    #   :place => Place object
    def fbplaces_url(options = {})
            url = "#{PLACES_FBURL}/"
            if options[:action] != nil && options[:action] != ""
                    url << "#{url_sanitize(options[:action].to_s)}/"
            end
            if options[:country] != nil && options[:country] != ""
                    url << "#{url_sanitize(options[:country])}/"
            end
            if options[:state] != nil && options[:state] != ""
                    url << "#{url_sanitize(options[:state])}/"
            end
            if options[:city] != nil && options[:city] != ""
                    url << "#{url_sanitize(options[:city])}/"
            end
            if options[:place] != nil && options[:place] != ""
                    url << "#{url_sanitize(options[:place])}/"
            end
            return url
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
		# Exceptions: 12:00 PM is unchanged, 12:00AM is 0:00
		if params["#{prefix}_time_ampm"] == "pm" && !hour.nil? && hour.to_i != 12
			hour = hour.to_i + 12
		elsif params["#{prefix}_time_ampm"] == "am" && !hour.nil? && hour.to_i == 12
			hour = 0
		end
		month = params["#{prefix}_date_mon"]
		day = params["#{prefix}_date_day"]
		year = params["#{prefix}_date_year"]
	
		puts "h=#{hour.to_i} m=#{minute.to_i} mo=#{month.to_i} d=#{day.to_i} y=#{year.to_i}"
		if hour.nil? || minute.nil? || month.nil? || day.nil? || year.nil?
			t = Time.new
		else
			t = Time.local(year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
		end
		return t
	end

    # This method takes a string and returns a suitable URL version.
    def url_sanitize(str)
            return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
    end

end
