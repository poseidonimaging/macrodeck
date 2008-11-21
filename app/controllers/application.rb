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
		if options[:place_action] != nil && options[:place_action] != ""
			url << "#{url_sanitize(options[:place_action].to_s)}/"
		end
		return url
	end

	# A URL helper that links to events
	def fbevents_url(options = {})
		url = "#{PLACES_FBURL}/calendar/"
		if options[:calendar] != nil && options[:calendar] != ""
			url << "#{url_sanitize(options[:calendar].to_s)}/"
		end
		if options[:action] != nil && options[:action] != ""
			url << "#{url_sanitize(options[:action].to_s)}/"
		end
		if options[:event] != nil && options[:event] != ""
			url << "#{url_sanitize(options[:event].to_s)}/"
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
			
			@fbuser = user

			# Parse friends list.
			if params["fb_sig_friends"]
				friend_uids = params["fb_sig_friends"].split(",")

				if session[:fb_friends_delchk].nil? || session[:fb_friends_delchk].class == Time
					session[:fb_friends_delchk] = {}
				end

				# Detect deletions
				@fbuser.friends.each do |f|
					if f.facebook_uid && f.facebook_uid != 0
						if session[:fb_friends_delchk].nil? || session[:fb_friends_delchk][f.facebook_uid].nil? || Time.now > session[:fb_friends_delchk][f.facebook_uid] + 5.minutes
							if !friend_uids.member?(f.facebook_uid)
								# Delete the friend association because they are no longer
								# friends on Facebook
								@fbuser.friends.delete(f)
							end

							session[:fb_friends_delchk][f.facebook_uid] = Time.now
						end
					end
				end

				# Only scan every 25 friends for insertions (doing it above would delete users inavertently
				session[:fb_friends_start] = 0 if session[:fb_friends_start].nil?
				total_friends = friend_uids.length
				friend_uids = friend_uids[session[:fb_friends_start] .. session[:fb_friends_start] + 24]
				
				# Increment the start value
				session[:fb_friends_start] = session[:fb_friends_start] + 25
				if session[:fb_friends_start] > total_friends
					session[:fb_friends_start] = 0
				end

				# Detect insertions
				# step 1: is the friend even in our system?
				friend_uids.each do |fid|
					if session[:fb_friends_inschk].nil? || session[:fb_friends_inschk][fid].nil? || Time.now > session[:fb_friends_inschk][fid] + 5.minutes
						# Initialize the hash if needed
						if session[:fb_friends_inschk].nil?
							session[:fb_friends_inschk] = {}
						end

						u = User.find_by_facebook_uid(fid)
						if u.nil?
							new_user = User.new do |usr|
								usr.facebook_uid = fid
							end
							new_user.save!
							u = new_user
						end

						# step 2: is friend associated?
						if @fbuser.friend_ids.nil? || !@fbuser.friend_ids.member?(u.id)
							@fbuser.friends << u
						end

						session[:fb_friends_inschk][fid] = Time.now
					end
				end
			end
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

	# This method gets all of the networks for the current fbsession user
	def get_networks
		response = fbsession.users_getInfo(:uids => fbsession.session_user_id, :fields => ["affiliations"])
		if response != nil && response.user != nil && response.user.affiliations_list != nil
			# XXX: We work with cities currently, so we have to only support regional networks right now.
			# College and work networks will be supported but we will have to have some sort of associated
			# city with each network. We will depend on our users for this information, and this requires more
			# UI and stuff.
			@networks = []
			@unsupported_networks = []

			response.user.affiliations.affiliation_list.each do |affiliation|
				p affiliation
	
				# Hack to support network mapping
				map_check = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'maps_to'", "fb:nid:#{affiliation.nid}"])
				if !map_check.nil?
					puts "*** Network is changing to a regional network (city=#{map_check.target_uuid})!"
					target_city = City.find_by_uuid(map_check.target_uuid)
					if !target_city.nil?
						# Get the internal Facepricot document, then modify it, then put it back into the result.
						# Ugly, doesn't update `to_s` for some reason, but still appears to work..?
						affiliation_name = affiliation.name
						facedoc = affiliation.instance_variable_get("@doc")
						facedoc.at("name").children[0] = Hpricot::Text.new("#{target_city.name}, #{target_city.state(:abbreviation => true)}")
						facedoc.at("type").children[0] = Hpricot::Text.new("region")
						facedoc.at("status").children[0] = Hpricot::Text.new("(#{affiliation_name})")
						affiliation.instance_variable_set("@doc", facedoc)
						puts "Affiliation is now #{affiliation.name}"
					end
				end

				# method_missing("type") is used because affiliation.type does not work
				# because type is a reserved Ruby method
				# Also, check for "/" as in "Dallas / Fort Worth, TX". We don't support
				# a regional network named like that yet.
				if affiliation.method_missing("type") == "region" && !(affiliation.name =~ /\//)
					@networks << affiliation

					# Create a city for each regional network when we detect them.
					aff_state = affiliation.name.split(",")[-1].chomp.strip
					aff_city = affiliation.name.split(",")[0].chomp.strip

					# Unless is backwards if. the following code is run always, unless
					# the city actually exists.
					unless PlacesService.isCity?(aff_city, aff_state) 
						puts "*** Places: Creating a new city: #{aff_city}, #{aff_state}"
						c = PlacesService.createCity(aff_city, aff_state)
						c.created_by_id = @fbuser.id
						c.save!
					end
				else
					@unsupported_networks << affiliation
				end
			end
			if @networks.length > 0
				@primary_network = @networks[0].name
				@primary_network_country = "US" # FIXME: This will need more support in the future when we support non-US places
				@primary_network_state = @networks[0].name.split(",")[-1].chomp.strip
				@primary_network_city = @networks[0].name.split(",")[0].chomp.strip
			else
				@primary_network = nil
				@primary_network_country = nil
				@primary_network_state = nil
				@primary_network_city = nil
			end
		else
			@primary_network = nil
			@primary_network_country = nil
			@primary_network_state = nil
			@primary_network_city = nil
			@networks = []
		end
	end

	# Gets the home city for the current user.
	def get_home_city
		hcity_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'home_city'", @fbuser.uuid])
		if hcity_rel.nil? && @primary_network != nil # the primary network may be nil if they don't have a regional network.
			# home city is nil.
			# This must mean there hasn't been one set. So we set the primary network city as the home city.
			hcity_rel = Relationship.new do |r|
				r.source_uuid = @fbuser.uuid
				c = PlacesService.getCity(@primary_network_city, @primary_network_state)
				if c != nil
					r.target_uuid = c.uuid 
				else
					raise "get_home_city: attempting to set home city to a city that does not exist!"
				end
				r.relationship = "home_city"
			end
			hcity_rel.save!
		end

		# See if we created it or not a minute ago...
		if hcity_rel.nil?
			@home_city = nil
		else
			hcity = City.find_by_uuid(hcity_rel.target_uuid)
			@home_city = hcity
		end
	end

	# Gets the secondary city for the current user. 
	def get_secondary_city
		scity_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'secondary_city'", @fbuser.uuid])
		if scity_rel.nil?
			@secondary_city = nil
		else
			scity = City.find_by_uuid(scity_rel.target_uuid)
			@secondary_city = scity
		end
	end

	# Removes fb_sig values from the params
	def fb_sig_cleanup
		params.delete("fb_sig")
		params.delete("fb_sig_time")
		params.delete("fb_sig_in_canvas")
		params.delete("fb_sig_position_fix")
		params.delete("fb_sig_session_key")
		params.delete("fb_sig_request_method")
		params.delete("fb_sig_expires")
		params.delete("fb_sig_added")
		params.delete("fb_sig_friends")
		params.delete("fb_sig_user")
		params.delete("fb_sig_api_key")
		params.delete("fb_sig_profile_update_time")
		params.delete("fb_sig_locale")
	end
end
