# This controller handles the Facebook app.
class FacebookPlacesController < ApplicationController
	before_filter :require_facebook_login, :initialize_facebook_user

	# view takes parameters like this:
	# view/:country/:state/:city/:place
	# If a parameter isn't specified, it is nil.
	#
	# View requires all parameters. You want to view a place.
	def view
	end

	# edit URLs look like view.
	def edit
	end
	
	# delete URLs look like view.
	def delete
	end

	# browse URLs look like view URLs presently. when browsing
	# by tags happens they might look different.
	def browse
		get_networks

		case params[:country]
			when "my_places"
				render :template => "facebook_places/browse_my_places"
			when "friends"
				render :template => "facebook_places/browse_friends"
			when "network"
				render :template => "facebook_places/browse_network"
			when "all"
				render :template => "facebook_places/browse_all"
			when "us"
				get_us_states

				if params[:state]
					# A state was specified. Either..
					# 1) browse a state (city = nil)
					# 2) browse a city (city != nil)
					if params[:city]
						# A city was specified.
						get_city_info(params[:city], params[:state])
						render :template => "facebook_places/browse_city"
					else
						# Browse the state (all cities). Should this be explicitly allowed?
						# States like Texas probably have a lot of cities. I dunno.
						get_cities(params[:state])
						render :template => "facebook_places/browse_state"
					end
				else
					# State not specified, show them all!
					render :template => "facebook_places/browse_country"
				end
		end
	end

	# create URLs are like view but different in one way:
	# create/:country/:state/:city/
	# You fill in the place name in the form!
	def create
		get_networks

		case params[:country]
			when "us"
				get_us_states

				if params[:state]
					# A state was specified, either...
					# 1) create a city (city == nil)
					# 2) create a place (city != nil)
					if params[:city]
						# Create a place.
						get_city_info(params[:city], params[:state])
						if params[:validation_step] == nil
							# Show the initial form.
							@place_types = get_place_type_option_list
							@place_features = get_place_feature_checkboxes
							@validation_step = 1
							@errors = []
							render :template => "facebook_places/create_place"
						elsif params[:validation_step] == "1"
							# get required variables for the form
							@place_types = get_place_type_option_list(params[:place_type])
							@place_features = get_place_feature_checkboxes(params[:place_features])
							@validation_step = 1
							# get params in variables
							@place_name = params[:place_name]
							@place_address = params[:place_address]
							@place_type = params[:place_type]
							@place_phone_number_area_code = params[:place_phone_number_area_code]
							@place_phone_number_exchange = params[:place_phone_number_exchange]
							@place_phone_number_number = params[:place_phone_number_number]
							if @place_phone_number_area_code.empty?
								@place_phone_number_area_code = nil
							end
							if @place_phone_number_exchange.empty?
								@place_phone_number_exchange = nil
							end
							if @place_phone_number_number.empty?
								@place_phone_number_number = nil
							end
							@place_description = params[:place_description]
							@place_zipcode = params[:place_zipcode]
							@place_latitude = params[:place_latitude]
							@place_longitude = params[:place_longitude]
							# TODO: features
							# TODO: hours
						
							# Yummy validation!
							@errors = []
							if !validate_not_nil(@place_name)
								@errors << "Please enter a place name."
							end
							if !validate_not_nil(@place_address)
								@errors << "Please enter an address."
							end
							if !validate_not_nil(@place_type) || @place_type == "none"
								@errors << "Please select a valid place type."
							end
							if @place_phone_number_area_code != nil || @place_phone_number_exchange != nil || @place_phone_number_number != nil
								if !validate_field("(#{@place_phone_number_area_code}) #{@place_phone_number_exchange}-#{@place_phone_number_number}", :phone)
									@errors << "Please enter a valid phone number."
								end
							end
							if !validate_field(@place_zipcode, :zipcode)
								@errors << "Please enter a valid zip code."
							end
							if @place_latitude != nil && !validate_field(@place_latitude, :latitude)
								@errors << "Please enter a valid latitude in decimal notation (e.g. 12.3456789)"
							end
							if @place_longitude != nil && !validate_field(@place_longitude, :longitude)
								@errors << "Please enter a valid longitude in decimal notation (e.g. 98.7654321)"
							end

							if @errors.length > 0
								render :template => "facebook_places/create_place"
							else
								# no validation errors.
								@errors << "debug: no errors!"
								@errors << params[:place_features].inspect
								render :template => "facebook_places/create_place"
							end
						end
					else
						# Create a city.
						if request.get?
							# This is a GET request; show the creation form.
							render :template => "facebook_places/create_city"
						elsif request.post?
							# This is a POST request; create the city and redirect to the city.
						end
					end
				else
					# No state specified, redirect to the browse URL for
					# whatever they attempted to create...
					redirect_to :back
				end
		end
	end

	# add_patronage looks like view. add_patronage says that
	# the user visiting the URL is a patron of the place.
	def add_patronage
	end

	# remove_patronage looks like view. remove_patronage says
	# that the user visiting the URL no longer goes to a place.
	# if the user never went to that place we shouldn't throw an
	# error.
	def remove_patronage
	end

	# RFacebook Debug Panel
	def debug
		get_networks

		render_with_facebook_debug_panel
	end

	private
		# Validates a field. Field types: :email, :phone, :latitude, :longitude, :zipcode
		def validate_field(value, type)
			case type
			when :email
				if value =~ EMAIL_VALIDATION
					return true
				else
					return false
				end
			when :phone
				if value =~ PHONE_VALIDATION
					return true
				else
					return false
				end
			when :latitude
				# latitude = -90 to +90
				if value.to_f <= 90.0 && value.to_f >= -90.0
					return true
				else
					return false
				end
			when :longitude
				# longitude = -180 to +180
				if value.to_f <= 180.0 && value.to_f >= -180.0
					return true
				else
					return false
				end
			when :zipcode
				if value != nil && !value.empty? && value.length == 5
					return true
				elsif value == nil || value.empty?
					# it is valid for a zipcode to be empty.
					return true
				else
					return false
				end
			end
		end

		# Returns true if not nil, false otherwise.
		def validate_not_nil(value)
			if value == nil || value.empty?
				return false
			else
				return true
			end
		end
		
		# This method takes a string and returns a suitable URL version.
		def url_sanitize(str)
			return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
		end

		# Returns an <option /> list containing place types (specify the selected value with a key if there is one)
		def get_place_type_option_list(default_value = nil)
			types = PlaceMetadata.get_place_types
			option_list = []
			types.each_pair do |key, value|
				if key != :other
					if default_value != nil && default_value.to_s == key.to_s
						option_list << "<option value=\"#{key.to_s}\" selected=\"selected\">#{value}</option>"
					else
						option_list << "<option value=\"#{key.to_s}\">#{value}</option>"
					end
				end
			end
			option_list.sort!
			if default_value != nil
				option_list.insert(0, "<option value=\"none\" class=\"invalid-selection\" disabled=\"disabled\">Select a Type</option>")
			else
				option_list.insert(0, "<option value=\"none\" class=\"invalid-selection\" selected=\"selected\" disabled=\"disabled\">Select a Type</option>")
			end
			# TODO: support for Other
			#option_list << "<option value=\"none\" class=\"seperator\" disabled=\"disabled\"></option>"
			#option_list << "<option value=\"other\">Other</option>"
			return option_list.to_s
		end

		# Returns a bunch of checkboxes for each feature available for a place; the enabled features should be specified as a hash like { :outdoor_seating => "1" } or { "outdoor_seating" => "1" }
		def get_place_feature_checkboxes(enabled_features = {})
			features = PlaceMetadata.get_place_features
			feature_list = []
			features.each_pair do |key, value|
				if enabled_features != nil && enabled_features[key.to_s] != nil && enabled_features[key.to_s] == "1"
					feature_list << "<input type=\"checkbox\" name=\"place_features[#{key.to_s}]\" value=\"1\" checked=\"checked\"/>
										<label for=\"place_#{key.to_s}\" class=\"standard\">#{value}</label><br />"
				else
					# feature isn't selected
					feature_list << "<input type=\"checkbox\" name=\"place_features[#{key.to_s}]\" value=\"1\" />
										<label for=\"place_#{key.to_s}\" class=\"standard\">#{value}</label><br />"
				end
			end
			feature_list.sort!
			columnized_feature_list = []

			if feature_list[0..6] != nil
				columnized_feature_list << "<div class=\"form-multicolumn-column\">"
				feature_list[0..6].each do |feature|
					columnized_feature_list << feature
				end
				columnized_feature_list << "</div>"
			end
			if feature_list[7..13] != nil
				columnized_feature_list << "<div class=\"form-multicolumn-column\">"
				feature_list[7..13].each do |feature|
					columnized_feature_list << feature
				end
				columnized_feature_list << "</div>"
			end
			if feature_list[14..-1] != nil
				columnized_feature_list << "<div class=\"form-multicolumn-column\">"
				feature_list[14..-1].each do |feature|
					columnized_feature_list << feature
				end
				columnized_feature_list << "</div>"
			end
			return columnized_feature_list.to_s
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
					# method_missing("type") is used because affiliation.type does not work
					# because type is a reserved Ruby method
					if affiliation.method_missing("type") == "region"
						@networks << affiliation

						# Create a city for each regional network when we detect them.
						aff_state = affiliation.name.split(",")[-1].chomp.strip
						aff_city = affiliation.name.split(",")[0].chomp.strip

						# Unless is backwards if. the following code is run always, unless
						# the city actually exists.
						unless PlacesService.isCity?(aff_city, aff_state) 
							puts "*** Places: Creating a new city: #{aff_city}, #{aff_state}"
							PlacesService.createCity(aff_city, aff_state)
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

		# Initialize Facebook User - Creates a User if needed, maps friends, etc. Use as a
		# before_filter.
		def initialize_facebook_user
			if fbsession && fbsession.is_valid?
				user = User.find_or_create_by_facebook_session(fbsession)
				# TODO: here we would load their friends list or whatever.
				@fbuser = user			
			end
		end

		# Gets all US states and puts them in @states
		def get_us_states
			places = Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"])
			@country = places.getChildByURL("us")

			if @country != nil
				@states = @country.children
			else
				raise "Country not found."
			end
		end

		# Gets all cities in a state and puts them in @cities
		def get_cities(state_url_part)
			places = Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"])
			@country = places.getChildByURL("us")
			if @country != nil
				@state = @country.getChildByURL(state_url_part)
				if @state != nil
					@cities = @state.children
				else
					raise "State not found."
				end
			else
				raise "Country not found."
			end
		end

		# Gets city information and stores it in variables so that the page can get them.
		def get_city_info(city_name, state)
			c = PlacesService.getCity(city_name,state)
			places = Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"])
			@country = places.getChildByURL("us")
			@state = @country.getChild(state)
			@city = c
		end
end
