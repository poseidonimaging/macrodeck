# This controller handles Places through a web browser.
# For the Facebook app, see FacebookPlacesController.
class PlacesController < ApplicationController
	layout 'default'

	def index
		# Do nothing. This is an advertisement page for the Places Facebook app right now.
	end

	def debug
		u = User.find_by_facebook_uid(654157670)
		p u

		render :text => "SUCCESS"
	end
end
