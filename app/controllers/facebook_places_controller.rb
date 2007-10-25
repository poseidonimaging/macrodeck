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
		case params[:country]
			when "us"
				get_us_states

				if params[:state]
					# A state was specified, either...
					# 1) create a city (city == nil)
					# 2) create a place (city != nil)
					if params[:city]
						# TODO: Create Place
					else
						# Create a city.
						if request.get?
							# This is a GET request; show the creation form.
						elsif request.post?
							# This is a POST request; create the city and redirect to the city.
						end
					end
				else
					# No state specified, redirect to the browse URL for
					# whatever they attempted to create...
					# TODO: Actually do this
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
			places = Category.find(:first, :conditions => ["parent IS NULL AND url_part = ?", "places"])
			@country = places.getChildByURL("us")

			if @country != nil
				@states = @country.children
			else
				raise "Country not found."
			end
		end

		# Gets all cities in a state and puts them in @cities
		def get_cities(state_url_part)
			places = Category.find(:first, :conditions => ["parent IS NULL AND url_part = ?", "places"])
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
			places = Category.find(:first, :conditions => ["parent IS NULL AND url_part = ?", "places"])
			@country = places.getChildByURL("us")
			@state = @country.getChild(state)
			@city = c
		end
end
