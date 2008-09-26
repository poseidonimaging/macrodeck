class FacebookEventsController < ApplicationController
	before_filter :require_facebook_login, :except => :parse_time
	before_filter :initialize_facebook_user, :except => :parse_time
	before_filter :setup_breadcrumbs, :except => :parse_time

	layout "facebook_events"

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
				populate_params_with_location_information(@calendar)

				@event_dtstart = EventService.parse_time(params["event_dtstart"]) unless params["event_dtstart"].nil?
				@event_dtstart = nil if params["event_dtstart"].nil?
				
				@event_dtend = EventService.parse_time(params["event_dtend"]) unless params["event_dtend"].nil?
				@event_dtend = nil if params["event_dtstart"].nil?

				@event_dtend_disable = params["event_dtend_disable"]
				@event_summary = params["event_summary"]
				@event_description = params["event_description"]
				@event_recurrence = params["event_recurrence"]
				@recurrence_rate_yearly = false
				@recurrence_rate_monthly = false
				@recurrence_rate_monthly_nth_nday = false
				@recurrence_rate_weekly = false
				if @event_recurrence
					case params["recurrence_rate"]
					when "yearly"
						@recurrence_rate_yearly = true
					when "monthly"
						@recurrence_rate_monthly = true
					when "monthly_nth_nday"
						@recurrence_rate_monthly_nth_nday = true
					when "weekly"
						@recurrence_rate_weekly = true
					end
				end
				@redirect = params["redirect"]
				@redirecturl = params["redirecturl"]
	
				if params[:create_event].nil?
					# display the form
					render :template => "facebook_events/create_event"
				else
					# validate the data and create the place
					@errors << "Your event must have a summary." if @event_summary.nil? || @event_summary.length == 0
					@errors << "Your event must have a start time." if @event_dtstart.nil?
					@errors << "Your event must have an end time." if @event_dtend.nil? && !@event_dtend_disable
					@errors << "Your event cannot end before it starts!" if !@event_dtstart.nil? && !@event_dtend.nil? && (!@event_dtend_disable && (@event_dtend < @event_dtstart))
					@errors << "Your event cannot start and end at the same time!" if !@event_dtstart.nil? && !@event_dtend.nil? && !@event_dtend_disable && (@event_dtend == @event_dtstart)
					@errors << "Your event cannot start in the past!" if !@event_dtstart.nil? && @event_dtstart < Time.now
					@errors << "Your event is set to recur but you have not set how often it is to recur." if @event_recurrence && (!@recurrence_rate_yearly && !@recurrence_rate_monthly && !@recurrence_rate_monthly_nth_nday && !@recurrence_rate_weekly)

					if @errors.length > 0
						render :template => "facebook_events/create_event"
					else
						# create the event.
						recurrence = :none # default
						recurrence = :yearly if @recurrence_rate_yearly
						recurrence = :monthly if @recurrence_rate_monthly
						recurrence = :monthly_nth_nday if @recurrence_rate_monthly_nth_nday
						recurrence = :weekly if @recurrence_rate_weekly

						if @event_dtend_disable
							extdata = { :start_time => @event_dtstart, :no_end_time => true, :recurrence => recurrence }
						else
							extdata = { :start_time => @event_dtstart, :end_time => @event_dtend, :no_end_time => false, :recurrence => recurrence }
						end
						e = Event.create(:extended_data => extdata, :title => @event_summary, :description => @event_description, :parent_id => @calendar.id,
								:created_by => @fbuser, :owned_by => @fbuser, :category_id => @calendar.category_id)

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
		get_networks
		get_home_city
		get_secondary_city

		if params[:calendar] != nil
			@calendar = Calendar.find_by_uuid(params[:calendar])
			if @calendar
				populate_params_with_location_information(@calendar)

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

	# Shows all of the events in a calendar's category
	def category
		get_networks
		get_home_city
		get_secondary_city

		if params[:calendar] != nil
			@calendar = Calendar.find_by_uuid(params[:calendar])
			if @calendar
				populate_params_with_location_information(@calendar)

				if @calendar.events
					if params[:show_all]
						@events = Calendar.events_in_category(@calendar.category_id).paginate(:page => params[:page], :per_page => 10)
					else
						@events = Calendar.upcoming_events_in_category(@calendar.category_id).paginate(:page => params[:page], :per_page => 10)
					end
				else
					@events = nil
				end
			else
				raise ArgumentError, "event#category - Calendar is missing!"
			end
		else
			raise ArgumentError, "event#category - Invalid calendar passed!"
		end
	end

	# Shows a specific event in a calendar
	def event
		get_networks
		get_home_city
		get_secondary_city

		if params[:calendar] != nil && params[:event] != nil
			@calendar = Calendar.find_by_uuid(params[:calendar])
			if @calendar
				populate_params_with_location_information(@calendar)

				@event = Event.find_by_uuid(params[:event])
				if @event
					if @event.concluded?
						@event.process_recurrence
					end
					render
				else
					raise ArgumentError, "event#event - Event is missing!"
				end
			else
				raise ArgumentError, "event#event - Calendar is missing!"
			end
		else
			raise ArgumentError, "event#event - Invalid calendar passed!"
		end
	end

	def attending
		get_networks
		get_home_city
		get_secondary_city

		if params[:calendar] != nil && params[:event] != nil
			# Mark this person as attending this event
			@event = Event.find_by_uuid(params[:event])

			if @event != nil
				attending_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship = 'attending'", @fbuser.uuid, params[:event]])
				if attending_rel.nil?
					# Yes we can mark them as attending
					attending = Relationship.new do |r|
						r.source_uuid = @fbuser.uuid
						r.target_uuid = params[:event]
						r.relationship = "attending"
					end
					attending.save!

					# TODO: post to facebook
				end
				redirect_to @event.url(:facebook => true)
			else
				raise ArgumentError, "event#attending - event not found"
			end
		else
			raise ArgumentError, "event#attending - not enough parameters"
		end
	end

	def not_attending
		get_networks
		get_home_city
		get_secondary_city

		if params[:calendar] != nil && params[:event] != nil
			# Mark this person as attending this event
			@event = Event.find_by_uuid(params[:event])

			if @event != nil
				attending_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship = 'attending'", @fbuser.uuid, params[:event]])
				if attending_rel
					attending.destroy
				end
				redirect_to @event.url(:facebook => true)
			else
				raise ArgumentError, "event#not_attending - event not found"
			end
		else
			raise ArgumentError, "event#not_attending - not enough parameters"
		end
	end

	def nudge
		get_networks
		get_home_city
		get_secondary_city

		if params[:calendar] != nil && params[:event] != nil && params[:name] != nil && params[:user] != nil
			# Mark this person as not attending this event
			@event = Event.find_by_uuid(params[:event])
			@user = User.find_by_facebook_uid(params[:user])

			if @event != nil && @user != nil
				nudge_rel = Relationship.find(:first, :conditions => ["source_uuid = ? AND target_uuid = ? AND relationship = 'nudged'", @user.uuid, params[:event]])
				if nudge_rel.nil?
					
					nudge = Relationship.new do |r|
						r.source_uuid = @user.uuid
						r.target_uuid = params[:event]
						r.relationship = "nudged"
					end
					nudge.save!			
				end
				# send a notification to the nudged person
				req = fbsession.notifications_send(:to_ids => @user.facebook_uid, :session_key => @user.facebook_session_key,
					:notification => "nudged you about <a href='#{@event.url(:facebook => true)}'>#{@event.summary}</a>, an event on <a href='#{PLACES_FBURL}/'><fb:application-name /></a>")
				redirect_to @event.url(:facebook => true)
			elsif @event != nil && @user.nil?
				raise ArgumentError, "event#nudge - target user not found"
			else
				raise ArgumentError, "event#nudge - event not found"
			end
		else
			raise ArgumentError, "event#nudge - not enough parameters"
		end
	end

	def wall 
		get_networks
		get_home_city
		get_secondary_city

		if params[:calendar] != nil && params[:event] != nil
			# Event wall
			
			@event = Event.find_by_uuid(params[:event])
			@calendar = @event.parent
			populate_params_with_location_information(@calendar)

			if @event != nil
				if params[:add_comment].nil? || params[:add_comment] == ""
					# View wall posts.
					comments = @event.wall.comments
					if comments != nil && comments.length > 0
						@comments = comments.paginate(:page => params[:page], :per_page => 10)
					else
						@comments = nil
					end
					render :template => "facebook_events/wall_view"
				else
					# Add a wall post
					if params[:message] != nil && params[:message].length > 0
						@event.wall.create_comment(params[:message], { :created_by => @fbuser, :owned_by => @fbuser })
					end
					# If they didn't specify a message just redirect them to the place anyway, just don't add the null message.
					redirect_to fbevents_url(:action => :event, :calendar => params[:calendar], :event => params[:event])
				end
			else
				raise "wall: place does not exist"
			end
		end
	end

	def parse_time
		parsed = EventService.parse_time(params[:time].chomp.strip.gsub(",", "").downcase)
		if !parsed.nil?
			# Day, Month 1st, 2008 at 12:00PM
			friendly_date = parsed.strftime("%A, %B ")
			friendly_date << parsed.day.to_s
			friendly_date << parsed.strftime(", %Y at %I:%M %p")
			friendly_date = friendly_date.chomp.strip
			puts friendly_date

			# now for recurrence helpers
			recurrence_yearly = parsed.strftime("%B ")
			recurrence_yearly << parsed.day.to_i.ordinalize
			recurrence_monthly = parsed.day.to_i.ordinalize
			nth = (parsed.day.to_f/7.0).ceil.ordinalize
			recurrence_monthly_nth_nday = "#{nth} "
			recurrence_monthly_nth_nday << parsed.strftime("%A")
			recurrence_weekly = parsed.strftime("%A")

			time_output = {	"friendly_date" => friendly_date,
							"recurrence_yearly" => "(every #{recurrence_yearly})",
							"recurrence_monthly" => "(the #{recurrence_monthly} of every month)",
							"recurrence_monthly_nth_nday" => "(every #{recurrence_monthly_nth_nday})",
							"recurrence_weekly" => "(every #{recurrence_weekly})",
							"error" => "0" }

			render :json => time_output.to_json
		else 
			render :json => { "error" => "1" }.to_json
		end
	end

	private
		def populate_params_with_location_information(calendar)
			if calendar.parent[:type] == "Place"
				params[:place] = calendar.parent.url_part
				params[:city] = calendar.parent.parent.url_part
				params[:state] = calendar.parent.parent.category.parent.url_part
				params[:country] = calendar.parent.parent.category.parent.parent.url_part
				puts "#{params[:place]} #{params[:city]} #{params[:state]} #{params[:country]}"
			elsif calendar.parent[:type] == "City"
				params[:place] = nil
				params[:city] = calendar.parent.url_part
				params[:state] = calendar.parent.category.parent.url_part
				params[:country] = calendar.parent.category.parent.parent.url_part
			end
		end

		# Set the basecrumbs for this controller.
		def setup_breadcrumbs
			@baseurl = "#{PLACES_FBURL}/calendar/"
			@basecrumb = Breadcrumb.new("Calendars", @baseurl)
			@places_basecrumb = Breadcrumb.new("Browse", "#{PLACES_FBURL}/browse/")
		end
end
