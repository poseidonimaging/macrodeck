gem 'flickr'

# This controller handles the Facebook app.
class FacebookPlacesController < ApplicationController
	before_filter :require_facebook_login, :initialize_facebook_user

	# view takes parameters like this:
	# view/:country/:state/:city/:place
	# If a parameter isn't specified, it is nil.
	#
	# View requires all parameters. You want to view a place.
	def view
		get_networks
		get_home_city
		get_secondary_city

		case params[:country]
		when "us"
			get_us_states

			if params[:state] && params[:city] && params[:place]
				get_city_info(params[:city], params[:state])
				@place = Place.find_by_dataid(params[:place])
				if @place != nil
					patron_relationship = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship = 'patron'", @fbuser.uuid, @place.dataid])
					if patron_relationship.nil?
						@place_is_patron = false
					else
						@place_is_patron = true
					end
					render :template => "facebook_places/view_place"
				else
					# place doesn't exist; redirect to the city's browse page (if it doesn't exist then browse_city will take care of it we hope)
					redirect_to "#{PLACES_FBURL}/browse/#{params[:country]}/#{params[:state]}/#{params[:city]}/"
				end
			end
		end
	end

	def set_home_city
		get_networks
		get_home_city

		case params[:country]
		when "us"
			get_us_states
			
			if params[:state] && params[:city]
				get_city_info(params[:city], params[:state])

				# Validate not setting the home city to the secondary city...
				if @secondary_city.nil? || @city.uuid != @secondary_city.uuid
					hcity_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'home_city'", @fbuser.uuid])
					if hcity_rel.nil?
						raise "set_home_city: home city relationship nonexistant"
					end

					hcity_rel.target_uuid = @city.uuid
					hcity_rel.save!
				end
				
				redirect_to fbplaces_url(:action => :browse, :country => @city.country, :state => @city.state(:abbreviation => true), :city => @city.url_part)
			else
				raise "set_home_city: city or state not specified"
			end
		else
			raise "set_home_city: invalid country specification"
		end
	end

	def set_secondary_city
		get_networks
		get_home_city
		get_secondary_city

		case params[:country]
		when "us"
			get_us_states
			
			if params[:state] && params[:city]
				get_city_info(params[:city], params[:state])

				# Validate not setting the home city as the secondary city...
				if @secondary_city.nil? || @home_city.uuid != @secondary_city.uuid
					scity_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'secondary_city'", @fbuser.uuid])
					if scity_rel.nil?
						scity_rel = Relationship.new do |r|
							r.source_uuid = @fbuser.uuid
							r.relationship = "secondary_city"
						end
					end

					scity_rel.target_uuid = @city.uuid
					scity_rel.save!
				end

				redirect_to fbplaces_url(:action => :browse, :country => @city.country, :state => @city.state(:abbreviation => true), :city => @city.url_part)
			else
				raise "set_secondary_city: city or state not specified"
			end
		else
			raise "set_secondary_city: invalid country specification"
		end
	end

	def welcome
		get_networks
		get_home_city
		get_secondary_city
		# Just static text.
	end

	# edit URLs look like view.
	def edit
		get_networks
		get_home_city
		get_secondary_city
		
		case params[:country]
			when "us"
				get_us_states

				if params[:state]
					if params[:city]
						if params[:place]
							@place = Place.find_by_dataid(params[:place])
							if @place.nil?
								redirect_to "#{PLACES_FBURL}/browse/#{params[:country]}/#{params[:state]}/#{params[:city]}/"
							else
								# Edit a place.
								get_city_info(params[:city], params[:state])
								if params[:validation_step] == nil
									# Show the initial form.
									@place_metadata = @place.place_metadata
									@place_types = get_place_type_option_list(@place_metadata[:type])
									@place_features = get_place_feature_checkboxes(@place_metadata[:features])
									@place_name = @place.title
									@place_address = @place_metadata[:address]
									if @place_metadata[:phone_number] != nil && @place_metadata[:phone_number].length > 5
										@place_phone_number_area_code = @place_metadata[:phone_number].gsub(/\W/, "")[0..2]
										@place_phone_number_exchange = @place_metadata[:phone_number].gsub(/\W/, "")[3..5]
										@place_phone_number_number = @place_metadata[:phone_number].gsub(/\W/, "")[6..9]
									else
										@place_phone_number_area_code = nil
										@place_phone_number_exchange = nil
										@place_phone_number_number = nil
									end
									@place_description = @place.description
									@place_zipcode = @place_metadata[:zipcode]
									@place_latitude = @place_metadata[:latitude]
									@place_longitude = @place_metadata[:longitude]
									@place_website = @place_metadata[:website]
									@place_hours_sunday = @place_metadata[:hours_sunday]
									@place_hours_monday = @place_metadata[:hours_monday]
									@place_hours_tuesday = @place_metadata[:hours_tuesday]
									@place_hours_wednesday = @place_metadata[:hours_wednesday]
									@place_hours_thursday = @place_metadata[:hours_thursday]
									@place_hours_friday = @place_metadata[:hours_friday]
									@place_hours_saturday = @place_metadata[:hours_saturday]
									@validation_step = 1
									@errors = []
									render :template => "facebook_places/edit_place"
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
									@place_website = params[:place_website]
									@place_feature_list = params[:place_features]
									@place_hours_sunday = params[:place_hours_sunday]
									@place_hours_monday = params[:place_hours_monday]
									@place_hours_tuesday = params[:place_hours_tuesday]
									@place_hours_wednesday = params[:place_hours_wednesday]
									@place_hours_thursday = params[:place_hours_thursday]
									@place_hours_friday = params[:place_hours_friday]
									@place_hours_saturday = params[:place_hours_saturday]
								
									# TODO: Combine create and edit validation into one function

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

									# TODO: Test to make sure this place at this address doesn't already exist.
									# TODO: Test the zipcode to make sure it's in this city.

									if @errors.length > 0
										render :template => "facebook_places/edit_place"
									else
										# create a metadata object
										# TODO: Make a function that does this for both create and edit.
										metadata = PlaceMetadata.new
										metadata.type = @place_type.to_sym
										metadata.address = @place_address
										metadata.zipcode = @place_zipcode
										if @place_phone_number_area_code.nil? && @place_phone_number_exchange.nil? && @place_phone_number_number.nil?
											metadata.phone_number = nil
										else
											metadata.phone_number = "(#{@place_phone_number_area_code}) #{@place_phone_number_exchange}-#{@place_phone_number_number}"
										end
										metadata.latitude = @place_latitude
										metadata.longitude = @place_longitude
										metadata.website = @place_website
										metadata.hours_sunday = @place_hours_sunday
										metadata.hours_monday = @place_hours_monday
										metadata.hours_tuesday = @place_hours_tuesday
										metadata.hours_wednesday = @place_hours_wednesday
										metadata.hours_thursday = @place_hours_thursday
										metadata.hours_friday = @place_hours_friday
										metadata.hours_saturday = @place_hours_saturday
										feature_array = []
										if @place_feature_list != nil
											@place_feature_list.each_key do |feature|
												feature_array << feature.to_sym
											end
										end
										metadata.features = feature_array
										@place.title = @place_name
										@place.description = @place_description
										@place.place_metadata = metadata
										@place.save!
										redirect_to "#{PLACES_FBURL}/view/#{@country.url_part}/#{@state.url_part}/#{url_sanitize(@city.title)}/#{@place.uuid}/"
									end # /@errors.length > 0
								end # /validation_step
							end # /place.nil?
						else 
							# TODO: City editing.
						end # / params[:place]
					else
						# No city specified.
						redirect_to "#{PLACES_FBURL}/browse/#{params[:country]}/#{params[:state]}/"
					end # /params[:city]
				end # /params[:state]
			else
				raise "Invalid country!"
		end # / case params[:country]
	end
	
	# delete URLs look like view.
	def delete
	end

	# browse URLs look like view URLs presently. when browsing
	# by tags happens they might look different.
	def browse
		get_networks
		get_home_city
		get_secondary_city

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
		get_home_city
		get_secondary_city

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
							@place_website = params[:place_website]
							@place_feature_list = params[:place_features]
							@place_hours_sunday = params[:place_hours_sunday]
							@place_hours_monday = params[:place_hours_monday]
							@place_hours_tuesday = params[:place_hours_tuesday]
							@place_hours_wednesday = params[:place_hours_wednesday]
							@place_hours_thursday = params[:place_hours_thursday]
							@place_hours_friday = params[:place_hours_friday]
							@place_hours_saturday = params[:place_hours_saturday]
						
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

							# TODO: Test to make sure this place at this address doesn't already exist.
							# TODO: Test the zipcode to make sure it's in this city.

							if @errors.length > 0
								render :template => "facebook_places/create_place"
							else
								# CREATE!
								metadata = PlaceMetadata.new
								metadata.type = @place_type.to_sym
								metadata.address = @place_address
								metadata.zipcode = @place_zipcode
								if @place_phone_number_area_code.nil? && @place_phone_number_exchange.nil? && @place_phone_number_number.nil?
									metadata.phone_number = nil
								else
									metadata.phone_number = "(#{@place_phone_number_area_code}) #{@place_phone_number_exchange}-#{@place_phone_number_number}"
								end
								metadata.latitude = @place_latitude
								metadata.longitude = @place_longitude
								metadata.website = @place_website
								metadata.hours_sunday = @place_hours_sunday
								metadata.hours_monday = @place_hours_monday
								metadata.hours_tuesday = @place_hours_tuesday
								metadata.hours_wednesday = @place_hours_wednesday
								metadata.hours_thursday = @place_hours_thursday
								metadata.hours_friday = @place_hours_friday
								metadata.hours_saturday = @place_hours_saturday
								feature_array = []
								if @place_feature_list != nil
									@place_feature_list.each_key do |feature|
										feature_array << feature.to_sym
									end
								end
								metadata.features = feature_array
								place = @city.create_place({ :title => @place_name, :description => @place_description })
								place.place_metadata = metadata
								place.save!
								redirect_to "#{PLACES_FBURL}/view/#{@country.url_part}/#{@state.url_part}/#{url_sanitize(@city.title)}/#{place.uuid}/"
							end
						end
					else
						get_state(params[:state])
						# Create a city.
						if params[:validation_step] == nil
							# show creation form
							@errors = []
							@validation_step = "1"
							render :template => "facebook_places/create_city"
						elsif params[:validation_step] == "1"
							# validate and then save the city
							# Capitalize first letter of the city name
							@city_name = params[:city_name].capitalize.chomp.strip
							@errors = []
							@validation_step = "1"
							if !validate_not_nil(@city_name)
								@errors << "Please enter a city name."
							end
							if @errors.length > 0
								render :template => "facebook_places/create_city"
							else
								city = PlacesService.createCity(@city_name, @state.title)
								if city != nil
									redirect_to "#{PLACES_FBURL}/browse/#{@country.url_part}/#{@state.url_part}/#{url_sanitize(city.title)}"
								else
									@errors << "The city you attempted to create already exists."
									render :template => "facebook_places/create_city"
								end
							end
						end
					end
				else
					# No state specified, redirect to the browse URL for
					# whatever they attempted to create...
					redirect_to "#{PLACES_FBURL}/browse/#{params[:country]}/"
				end
		end
	end

	# add_patronage looks like view. add_patronage says that
	# the user visiting the URL is a patron of the place.
	def add_patronage
		get_networks
		get_home_city

		case params[:country]
		when "us"
			get_us_states

			if params[:state] && params[:city] && params[:place]
				get_city_info(params[:city], params[:state])
				@place = Place.find_by_dataid(params[:place])
				if @place != nil
					patron_relationship = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship = 'patron'", @fbuser.uuid, @place.dataid])
					if patron_relationship.nil?
						# Add patronage.
						patronage = Relationship.new do |r|
							r.source_uuid = @fbuser.uuid
							r.target_uuid = @place.dataid
							r.relationship = "patron"
						end
						patronage.save!
					end
					# Don't do anything if they are already a patron.
				end
				redirect_to "#{PLACES_FBURL}/view/#{params[:country]}/#{params[:state]}/#{params[:city]}/#{@place.dataid}/"
			end
		end
	end

	# remove_patronage looks like view. remove_patronage says
	# that the user visiting the URL no longer goes to a place.
	# if the user never went to that place we shouldn't throw an
	# error.
	def remove_patronage
		get_networks
		get_home_city

		case params[:country]
		when "us"
			get_us_states

			if params[:state] && params[:city] && params[:place]
				get_city_info(params[:city], params[:state])
				@place = Place.find_by_dataid(params[:place])
				if @place != nil
					patron_relationship = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship = 'patron'", @fbuser.uuid, @place.dataid])
					if patron_relationship != nil
						# Remove patronage.
						patron_relationship.destroy
					end
					# Don't do anything if they aren't a patron.
				end
				redirect_to "#{PLACES_FBURL}/view/#{params[:country]}/#{params[:state]}/#{params[:city]}/#{@place.dataid}/"
			end
		end
	end

	# RFacebook Debug Panel
	def debug
		get_networks
		get_home_city
		get_secondary_city

		flickr = Flickr.new(FLICKR_API_KEY)
		photos = flickr.tag(@home_city.name.downcase.gsub(" ", "") + " " + @home_city.state(:abbreviation => true).downcase)
		photos.each do |photo|
			p photo
		end
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
			# support for an array e.g. [ :outdoor_seating, :chicken, :etc ]
			if enabled_features.class == Array && enabled_features.length > 0
				new_enabled_features = {}
				enabled_features.each do |f|
					new_enabled_features[f.to_s] = "1"
				end
				enabled_features = new_enabled_features
			end
			features.each_pair do |key, value|
				if enabled_features != nil && enabled_features.length > 0 && enabled_features[key.to_s] != nil && enabled_features[key.to_s] == "1"
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

		# Gets the home city for the current user.
		def get_home_city
			hcity_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND relationship = 'home_city'", @fbuser.uuid])
			if hcity_rel.nil?
				# home city is nil.
				# This must mean there hasn't been one set. So we set the primary network city as the home city.
				hcity_rel = Relationship.new do |r|
					r.source_uuid = @fbuser.uuid
					c = PlacesService.getCity(@primary_network_city, @primary_network_state)
					if c != nil
						r.target_uuid = c.uuid # FIXME: dataid can go to hell
					else
						raise "get_home_city: attempting to set home city to a city that does not exist!"
					end
					r.relationship = "home_city"
				end
				hcity_rel.save!
			end
			hcity = City.find_by_uuid(hcity_rel.target_uuid)
			@home_city = hcity
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

		def get_state(state_url_part)
			places = Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"])
			@country = places.getChildByURL("us")
			if @country != nil
				@state = @country.getChildByURL(state_url_part)
				if @state.nil?
					raise "State not found."
				end
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
end
