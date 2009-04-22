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
			minifeed = HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/minifeed.fbml'", @fbuser.id])
			@minifeed_content = minifeed.content
			@minifeed_caption = render_to_string(:partial => "facebook/home/recent_activity", :locals => { :item => minifeed })
		else
			@minifeed_content = "<p style='text-align: center;'>There are currently no entries in your minifeed.</p>"
			@minifeed_caption = nil
		end

		if HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/recommendations.fbml'", @fbuser.id])
			recs = HtmlPart.find(:first, :conditions => ["user_id = ? AND urn = 'macrodeck/home/recommendations.fbml'", @fbuser.id])
			@recommendations_content = recs.content
			@recommendations_caption = render_to_string(:partial => "facebook/home/recent_activity", :locals => { :item => recs })
		else
			@recommendations_content = "<p style='text-align: center;'>There are currently no recommendations to show.</p>"
			@recommendations_caption = nil
		end
	end

	private
		# XXX: This needs to move to PlaceMetadata and stay there...
		def place_type_to_string(type)
			types = PlaceMetadata.get_place_types
			return types[type]
		end
end
