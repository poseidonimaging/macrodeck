class FacebookEventsController < ApplicationController
	# Create an event.
	# Expects the following URL parameters to exist:
	# country, state, city, place
	def create
		if !params[:country].nil? && !params[:state].nil? && !params[:city].nil? && !params[:place].nil?
			if params[:create_event].nil?
				# display create event box
			else
				# actually create the event
			end
		else
			raise ArgumentError, "event#create - Required URL component missing"
		end
	end
end
