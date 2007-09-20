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
		# This method gets all of the networks for the current fbsession user
		def get_networks
			response = fbsession.users_getInfo(:uids => fbsession.session_user_id, :fields => ["affiliations"])
			if response != nil && response.user != nil && response.user.affiliations_list != nil
				@primary_network = response.user.affiliations.affiliation_list[0].name
				@primary_network_nid = response.user.affiliations.affiliation_list[0].nid
				@networks = response.user.affiliations.affiliation_list
			else
				@primary_network = "Network"
				@networks = []
			end
		end

		# Initialize Facebook User - Creates a User if needed, maps friends, etc. Use as a
		# before_filter.
		def initialize_facebook_user
			if fbsession && fbsession.is_valid?
				user = User.find_or_create_by_facebook_session(fbsession)
				# here we would load their friends list or whatever.
				@fbuser = user			
			end
		end

		# Gets all US states and puts them in @states
		def get_us_states
			places = Category.find(:first, :conditions => ["parent IS NULL AND url_part = ?", "places"])
			usa = places.getChildByURL("us")
			@states = usa.children
		end
end
