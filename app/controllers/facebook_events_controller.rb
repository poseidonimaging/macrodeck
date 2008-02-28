class FacebookEventsController < ApplicationController
	before_filter :require_facebook_login, :initialize_facebook_user

	# Create an event.
	# Expects the following URL parameters to exist:
	# calendar (uuid)
	# There is an optional option, redirect, which can be true or false, and if it's true, it redirects to
	# redirecturl, which is another option, when it finishes.
	def create
		get_networks
		get_home_city
		get_secondary_city

		if !params[:calendar].nil?
			@calendar = Calendar.find_by_uuid(params[:calendar])
			@errors = []
			if @calendar.nil?
				raise ArgumentError, "event#create - Calendar specified is invalid"
			else
				@event_dtstart = date_from_params("event_dtstart")
				@event_dtend = date_from_params("event_dtend")
				@event_dtend_enable = params["event_dtend_enable"]
				@event_summary = params["event_summary"]
				@event_description = params["event_description"]
				@event_recurrence = params["event_recurrence"]
				@redirect = params["redirect"]
				@redirecturl = params["redirecturl"]
	
				if params[:create_event].nil?
					# display the form
					render :template => "facebook_events/create_event"
				else
					# validate the data and create the place
					@errors << "Your event must have a summary." if @event_summary.nil? || @event_summary.length == 0
					@errors << "Your event cannot end before it starts!" if @event_dtend < @event_dtstart
					@errors << "Your event cannot start and end at the same time!" if @event_dtend == @event_dtstart
					@errors << "Your event cannot start in the past!" if @event_dtstart < Time.now

					if @errors.length > 0
						render :template => "facebook_events/create_event"
					else
						# create the event.
						extdata = { :start_time => @event_dtstart, :end_time => @event_dtend }
						e = Event.create(:extended_data => extdata, :title => @event_summary, :description => @event_description, :parent_id => @calendar.id,
										 :created_by => @fbuser, :owned_by => @fbuser)

						if @redirect
							if @redirecturl =~ /^http:\/\/apps.facebook.com\/macrodeck/
								redirect_to @redirecturl
							else
								puts "*** Events: Attempted to redirect to an invalid URL!"
							end
						else
							redirect_to fbevents_url(:calendar => @calendar.uuid, :action => :events)
						end
					end
				end
			end
		else
			raise ArgumentError, "event#create - Required URL component missing"
		end
	end

	# Shows all of the events in a calendar
	def events
		if params[:calendar] != nil
			@calendar = Calendar.find_by_uuid(params[:calendar])
			if @calendar
				if @calendar.events
					if params[:show_all]
						@events = @calendar.events.paginate(:page => params[:page], :per_page => 10)
					else
						@events = @calendar.upcoming_events.paginate(:page => params[:page], :per_page => 10)
					end
				else
					@events = nil
				end
			else
				raise ArgumentError, "event#events - Calendar is missing!"
			end
		else
			raise ArgumentError, "event#events - Invalid calendar passed!"
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
