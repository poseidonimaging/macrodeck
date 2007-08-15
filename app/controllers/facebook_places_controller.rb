# This controller handles the Facebook app.
class FacebookPlacesController < ApplicationController
	before_filter :require_facebook_login

	# view takes parameters like this:
	# view/:country/:state/:city/:place
	# If a parameter isn't specified, it is nil.
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
		get_primary_network

		case params[:country]
			when "my_places"
				render :template => "facebook_places/browse_my_places"
			when "friends"
				render :template => "facebook_places/browse_friends"
			when "network"
				render :template => "facebook_places/browse_network"
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
		@network = get_primary_network

		#render_with_facebook_debug_panel
	end

	# This method gets the primary network for the current fbsession user
	def get_primary_network
		response = fbsession.users_getInfo(:uids => fbsession.session_user_id, :fields => ["first_name", "last_name", "affiliations"])
		network = response.to_yaml
		render :text => "<pre>#{network}</pre>"
	end
end
