class Facebook::HomeController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	before_filter :get_networks
	before_filter :get_home_city
	before_filter :get_secondary_city
	layout "facebook/home"

	def index
		# Build the recommendations box.
		if HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/minifeed.fbml'", @fbuser.id])
			@minifeed_content = HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/minifeed.fbml'", @fbuser.id]).content
		else
			@minifeed_content = "<p style='text-align: center;'>There are currently no entries in your minifeed.</p>"
		end

		if HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/recommendations.fbml'", @fbuser.id])
			@recommendations_content = HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/recommendations.fbml'", @fbuser.id]).content
		else
			@recommendations_content = "<p style='text-align: center;'>There are currently no recommendations to show.</p>"
		end
	end

	private
		# XXX: This needs to move to PlaceMetadata and stay there...
		def place_type_to_string(type)
			types = PlaceMetadata.get_place_types
			return types[type]
		end
end
