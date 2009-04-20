class Facebook::HomeController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	before_filter :get_networks
	before_filter :get_home_city
	before_filter :get_secondary_city
	layout "facebook/home"

	def index
		# Build the recommendations box.

	end



	private
		# XXX: This needs to move to PlaceMetadata and stay there...
		def place_type_to_string(type)
			types = PlaceMetadata.get_place_types
			return types[type]
		end
end
