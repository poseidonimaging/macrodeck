# This controller handles the Facebook app.
class FacebookPlacesController < ApplicationController
	before_filter :require_facebook_login, :initialize_facebook_user

	# view takes parameters like this:
	# view/:country/:state/:city/:place
	# If a parameter isn't specified, it is nil.
	def view
		get_networks
		get_home_city
		get_secondary_city

		case params[:country]
		when "us"
			get_us_states

			if params[:state] && params[:city] && params[:place].nil?
				get_city_info(params[:city], params[:state])
				render :template => "facebook_places/view_city"
			elsif params[:state] && params[:city] && params[:place]
				get_city_info(params[:city], params[:state])
				@place = Place.find_by_dataid(params[:place])
				if @place != nil
					patron_relationship = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship = 'patron'", @fbuser.uuid, @place.dataid])
					if patron_relationship.nil?
						@place_is_patron = false
					else
						@place_is_patron = true
					end
					@place_features = get_place_features_as_list(@place.place_metadata[:features])
					@place_type = place_type_to_string(@place.place_metadata[:type])
					render :template => "facebook_places/view_place"
				else
					# place doesn't exist; redirect to the city's browse page (if it doesn't exist then browse_city will take care of it we hope)
					redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part)
				end
			end
		end
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
						# FYI: This used to be the view city page but then I realized that was dumb
						# Browse City is now a listing of places.
						get_city_info(params[:city], params[:state])
						@places = Place.paginate(:conditions => ["datatype = ? AND grouping = ?", DTYPE_PLACE, @city.uuid], :order => "title ASC", :page => params[:page], :per_page => 10)
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
						hcity_rel = Relationship.new
					end
					hcity_rel.source_uuid = @fbuser.uuid
					hcity_rel.target_uuid = @city.uuid
					hcity_rel.relationship = "home_city"
					hcity_rel.save!
				end
				
				redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part)
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

				redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part)
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
		# Render the page if they haven't been to the welcome page this session
		if session[:seen_welcome_page].nil? || params[:default].nil?
			session[:seen_welcome_page] = true
			render
		else
			if @home_city != nil
				redirect_to fbplaces_url(:action => :view, :country => @home_city.country.downcase, :state => @home_city.state(:abbreviation => true).downcase, :city => @home_city.url_part)
			else
				render
			end
		end
	end

	# Invite your friends
	def invite
		get_networks
		get_home_city
		get_secondary_city
	end

	def install
		require_facebook_install
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
							# Edit a place.
							get_city_info(params[:city], params[:state])
							@place = Place.find_by_dataid(params[:place])

							if @place.nil?
								redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part)
							else
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
										redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part, :place => @place.url_part)
									end # /@errors.length > 0
								end # /validation_step
							end # /place.nil?
						else 
							# TODO: City editing.
						end # / params[:place]
					else
						# No city specified.
						redirect_to fbplaces_url(:action => :browse, :country => @country.url_part, :state => params[:state])
					end # /params[:city]
				end # /params[:state]
			else
				raise "Invalid country!"
		end # / case params[:country]
	end
	
	# delete URLs look like view.
	def delete
		# TODO
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
								redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part, :place => place.url_part)
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
							if @city_name =~ /\//
								@errors << "Please don't enter metropolitan areas such as 'Dallas/Fort Worth'; instead create each city individually."
							end
							if @errors.length > 0
								render :template => "facebook_places/create_city"
							else
								city = PlacesService.createCity(@city_name, @state.title)
								if city != nil
									city.creator = @fbuser.uuid
									city.save!
									redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => city.url_part)
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
					redirect_to fbplaces_url(:action => :browse, :country => params[:country])
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

						action_message = "{actor} is now a patron of {place} using <a href=\"http://apps.facebook.com/macrodeckplaces/\">Places</a>."
						action_place = "<a href='#{fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part, :place => @place.url_part)}'>#{@place.name}</a>"
						action_json = "{\"place\":\"#{action_place}\"}"
						req = fbsession.feed_publishTemplatizedAction(:actor_id => @fbuser.facebook_uid, :title_template => action_message, :title_data => action_json)
					end
					# Don't do anything if they are already a patron.
				end
				redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part, :place => @place.url_part)
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
				redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part, :place => @place.url_part)
			end
		end
	end

	def view_photo
		get_networks
		get_home_city
		get_secondary_city
		fb_sig_cleanup

		if params[:country] != nil && params[:country] == "us" && params[:state] != nil && params[:city] != nil
			get_us_states
			get_city_info(params[:city], params[:state])
			flickr = Flickr.new(FLICKR_API_KEY)
			
			if params[:place].nil?
				# Set photo for city
				raise "TODO: Get photo for city"
			else
				@place = Place.find_by_uuid(params[:place])
				if @place != nil
					@photo = Flickr::Photo.new(@place.place_metadata[:flickr_photo_id])
					render :template => "facebook_places/view_photo_place"
				else
					raise "view_photo: place does not exist"
				end
			end
		end
	end

	def wall 
		get_networks
		get_home_city
		get_secondary_city

		if params[:country] != nil && params[:country] == "us" && params[:state] != nil && params[:city] != nil && params[:place] != nil
			get_us_states
			get_city_info(params[:city], params[:state])
			
			@place = Place.find_by_uuid(params[:place])
			if @place != nil
				if params[:add_comment].nil? || params[:add_comment] == ""
					# View wall posts.
					comments = @place.wall.comments
					if comments != nil && comments.length > 0
						@comments = comments.paginate(:page => params[:page], :per_page => 10)
					else
						@comments = nil
					end
					render :template => "facebook_places/wall_view"
				else
					# Add a wall post
					if params[:message] != nil && params[:message].length > 0
						@place.wall.create_comment(params[:message], { :creator => @fbuser.uuid, :owner => @fbuser.uuid })
					end
					# If they didn't specify a message just redirect them to the place anyway, just don't add the null message.
					redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part, :place => @place.uuid)
				end
			else
				raise "wall: place does not exist"
			end
		end
	end

	# Sets the photo for a city/place
	def change_photo
		get_networks
		get_home_city
		get_secondary_city
		fb_sig_cleanup
		
		if params[:country] != nil && params[:country] == "us" && params[:state] != nil && params[:city] != nil
			get_us_states
			get_city_info(params[:city], params[:state])
			flickr = Flickr.new(FLICKR_API_KEY)
			
			if params[:place].nil?
				# Set photo for city
				raise "TODO: Set photo for city"
			else
				@place = Place.find_by_uuid(params[:place])
				if @place != nil
					if params[:photo].nil?
						# e.g. "Wonder Waffle Okmulgee, OK" => "wonder waffle okmulgee"
						# since we're not searching by tag and instead by relevance, this works better.
						searchfor_first = @place.name.downcase + " " + @city.name.downcase
						searchfor_second = @place.name.downcase.gsub(/\W/, "") + " " + @city.name.downcase

						photo_req = flickr.photos_search(:text => searchfor_first, :sort => "relevance", :per_page => "15")
						photo_req_alt = flickr.photos_search(:text => searchfor_second, :sort => "relevance", :per_page => "15")

						# Merge the photo lists together
						if photo_req["photos"]["photo"].class == Array && photo_req_alt["photos"]["photo"].class == Array
							photo_req["photos"]["photo"] = photo_req["photos"]["photo"] | photo_req_alt["photos"]["photo"]
						elsif photo_req["photos"]["photo"].class == Hash && photo_req_alt["photos"]["photo"].class == Hash
							photo_req["photos"]["photo"] = [ photo_req["photos"]["photo"] ] | [ photo_req_alt["photos"]["photo"] ]
						elsif photo_req["photos"]["photo"].class == Array && photo_req_alt["photos"]["photo"].class == Hash
							photo_req["photos"]["photo"] = photo_req["photos"]["photo"] | [ photo_req_alt["photos"]["photo"] ]
						elsif photo_req["photos"]["photo"].class == Hash && photo_req_alt["photos"]["photo"].class == Array
							photo_req["photos"]["photo"] = [ photo_req["photos"]["photo"] ] | photo_req_alt["photos"]["photo"]
						else
							raise "change_photo: unhandled search merge"
						end

						if photo_req["photos"]["photo"] != nil
							if photo_req["photos"]["photo"].class == Array
								# more than one result
								photos = photo_req["photos"]["photo"].collect do |photo|
									Flickr::Photo.from_request(photo)
								end
							else
								# one result (putting in an array so I don't have to hack Paginate elsewhere)
								photos = [Flickr::Photo.from_request(photo_req["photos"]["photo"])]
							end
							@photos = photos.paginate(:page => params[:page], :per_page => 6)
							render :template => "facebook_places/change_photo_place"
						else
							# No results.
							@photos = nil
							render :template => "facebook_places/change_photo_place"
						end
					else
						# showing a single photo.
						if params[:select].nil? || params[:select] != "1"
							@photo = Flickr::Photo.new(params[:photo])
							render :template => "facebook_places/change_photo_place"
						else
							# TODO: Make this work in one line instead.
							meta = @place.place_metadata
							meta.flickr_photo_id = params[:photo]
							@place.place_metadata = meta
							@place.save!
							redirect_to fbplaces_url(:action => :view, :country => @country.url_part, :state => @state.url_part, :city => @city.url_part, :place => @place.uuid)
						end
					end
				else
					raise "change_photo: Place does not exist!"
				end
			end
		end
	end

	# RFacebook Debug Panel
	def debug
		get_networks
		get_home_city
		get_secondary_city
		fb_sig_cleanup
		flickr = Flickr.new(FLICKR_API_KEY)
		photo_req = flickr.photos_search(:text => "(santa rita austin) OR (santarita austin)", :sort => "relevance")
		p photo_req
	end

	private
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
		end

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

		# Takes a symbol corresponding to a place type and returns a human readable string
		def place_type_to_string(type)
			types = PlaceMetadata.get_place_types
			return types[type]
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

		# Returns HTML for the image for a feature (used in feature list)
		def image_for_feature(feature)
			case feature
			when :breakfast, :lunch, :dinner
				return "<img src=\"#{PLACES_BASEURL}/images/icons/small/standard-black/fork.png\" class=\"inline\" alt=\"Info\" />"
			when :full_bar, :wine, :byob, :beer
				return "<img src=\"#{PLACES_BASEURL}/images/icons/small/standard-black/alcohol.png\" class=\"inline\" alt=\"Info\" />"
			when :call_ahead
				return "<img src=\"#{PLACES_BASEURL}/images/icons/small/standard-black/phone.gif\" class=\"inline\" alt=\"Info\" />"
			when :outdoor_seating
				return "<img src=\"#{PLACES_BASEURL}/images/icons/small/standard-black/outdoor.png\" class=\"inline\" alt=\"Info\" />"
			when :free_wifi, :pay_wifi
				return "<img src=\"#{PLACES_BASEURL}/images/icons/small/standard-black/signal.gif\" class=\"inline\" alt=\"Info\" />"
			when :cash_only
				return "<img src=\"#{PLACES_BASEURL}/images/icons/small/standard-black/exclamation.gif\" class=\"inline\" alt=\"Info\" />"
			else
				return "<img src=\"#{PLACES_BASEURL}/images/icons/small/standard-black/info.gif\" class=\"inline\" alt=\"Info\" />"
			end
		end

		# Returns a <ul /> containing all of the features a place has.
		def get_place_features_as_list(features)
			all_features = PlaceMetadata.get_place_features
			feature_list = []
			if features != nil && features.length > 0
				features.each do |feature|
					feature_list << "<li class=\"#{feature.to_s}\">#{image_for_feature(feature)}<span>#{all_features[feature]}</span></li>"
				end
				feature_list.sort!
				final_feature_list = ["<ul class=\"features\">"]
				final_feature_list << feature_list
				final_feature_list << "</ul>"
				return final_feature_list.to_s
			else
				return nil
			end
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
							c.creator = @fbuser.uuid
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
						r.target_uuid = c.uuid # FIXME: dataid can go to hell
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
