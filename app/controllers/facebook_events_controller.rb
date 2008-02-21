class FacebookEventsController < ApplicationController
	before_filter :require_facebook_login, :initialize_facebook_user

	# Create an event.
	# Expects the following URL parameters to exist:
	# calendar (uuid)
	# There is an optional option, redirect, which can be true or false, and if it's true, it redirects to
	# redirecturl, which is another option, when it finishes.
	def create
		if !params[:calendar].nil?
			@calendar = Calendar.find_by_uuid(params[:calendar])
			@errors = []
			if @calendar.nil?
				raise ArgumentError, "event#create - Calendar specified is invalid"
			else
				@event_dtstart = params["event_dtstart"]
				@event_dtend = params["event_dtend"]
				@event_summary = params["event_summary"]
				@event_description = params["event_description"]
				@event_recurrence = params["event_recurrence"]
				@redirect = params["redirect"]
				@redirecturl = params["redirecturl"]
	
				if params[:create_event].nil?
					# display the form
					render :template => "facebook_events/create_event.rhtml"
				else
					# validate the data and create the place
				end
			end
		else
			raise ArgumentError, "event#create - Required URL component missing"
		end
	end

	# Fills in some redirect stuff and then calls create.
	def create_from_places
		# get calendar uuid
		place = Place.find_by_uuid(params[:place])
		if place.nil?
			raise ArgumentError, "event#create_from_places - Required URL component invalid"
		else
			calendar_uuid = place.calendar.uuid
		end
		params["redirect"] = true
		params["redirecturl"] = fbplaces_url(:action => :view, :country => params[:country], :state => params[:state], :city => params[:city], :place => params[:place])
		params["calendar"] = calendar_uuid
		
		# now run create
		create
	end
end
