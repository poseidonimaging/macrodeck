# This controller does all of the magic for events
class EventsController < ApplicationController
    layout 'restlessnapkin'
    before_filter :find_country
    before_filter :find_state
    before_filter :find_city
    before_filter :find_place
    before_filter :find_calendar
    before_filter :find_event

    # List events
    def index
	if @place.nil?
	    @events = @city.upcoming_events
	else
	    @events = @place.events
	end

	respond_to do |format|
	    format.html # index.html.erb
	end
    end

    # This is the main page for an event.
    def show
	respond_to do |format|
	    format.html # index.html.erb
	end
    end
	
    # Shows the interface for editing an event.
    def edit
	respond_to do |format|
	    format.html # edit.html.erb
	end
    end

    # Shows the interface for creating an event.
    def new
	@event = @calendar.events.new
	respond_to do |format|
	    format.html # new.html.erb
	end
    end
	
    # Handles updating an event
    def update
	if @event.update_attributes(params[:event])
	    if @place.nil?
		respond_to do |format|
		    format.html { redirect_to(country_state_city_event_path(params[:country_id], params[:state_id], params[:city_id], params[:id])) }
		    format.xml  { head :ok }
		end
	    else
		respond_to do |format|
		    format.html { redirect_to(country_state_city_place_event_path(params[:country_id], params[:state_id], params[:city_id], params[:place_id], params[:id])) }
		    format.xml  { head :ok }
		end
	    end
	else
	    respond_to do |format|
		format.html { render :action => "edit" }
		format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
	    end
	end
    end
	
    # Handles creating an event.
    def create
	@event = @calendar.events.build(params[:event])
	if @event.save
	    if @place.nil?
		respond_to do |format|
		    format.html { redirect_to(country_state_city_event_path(params[:country_id], params[:state_id], params[:city_id], @event.url_part)) }
		    format.xml  { head :ok }
		end
	    else
		respond_to do |format|
		    format.html { redirect_to(country_state_city_place_event_path(params[:country_id], params[:state_id], params[:city_id], params[:place_id], @event.url_part)) }
		    format.xml  { head :ok }
		end
	    end
	else
	    respond_to do |format|
		format.html { render :action => "edit" }
		format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
	    end
	end
    end
	
    # This is the ajax action that gets called when someone types in the date
    # field
    def ajax_parse_time
	parsed = EventService.parse_time(params[:time].chomp.strip.gsub(",", "").downcase)
	if !parsed.nil?
	    # Day, Month 1st, 2008 at 12:00PM
	    friendly_date = parsed.strftime("%A, %B ")
	    friendly_date << parsed.day.to_s
	    friendly_date << parsed.strftime(", %Y at %I:%M %p")
	    friendly_date = friendly_date.chomp.strip

	    # now for recurrence helpers
	    recurrence_yearly = parsed.strftime("%B ")
	    recurrence_yearly << parsed.day.to_i.ordinalize
	    recurrence_monthly = parsed.day.to_i.ordinalize
	    nth = (parsed.day.to_f/7.0).ceil.ordinalize
	    recurrence_monthly_nth_nday = "#{nth} "
	    recurrence_monthly_nth_nday << parsed.strftime("%A")
	    recurrence_weekly = parsed.strftime("%A")

	    time_output = {
		"friendly_date" => friendly_date,
		"recurrence_yearly" => "(every #{recurrence_yearly})",
		"recurrence_monthly" => "(the #{recurrence_monthly} of every month)",
		"recurrence_monthly_nth_nday" => "(every #{recurrence_monthly_nth_nday})",
		"recurrence_weekly" => "(every #{recurrence_weekly})",
		"error" => "0"
	    }

	    render :json => time_output.to_json
	else
	    render :json => { "error" => "1" }.to_json
	end
    end

    private
    # Finds the country associated with the request.
    def find_country
	@country = Category.find_by_parent_uuid_and_url_part(Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid, params[:country_id].downcase) if params[:country_id]
    end

    # Finds the state associated with the request.
    def find_state
	@state = Category.find_by_parent_uuid_and_url_part(@country.uuid, params[:state_id].downcase) if params[:country_id] && params[:state_id]
    end

    # Finds the city associated with the request
    def find_city
	if params[:country_id] && params[:state_id] && params[:city_id]
	    # Walk the tree
	    city_category = Category.find_by_parent_uuid_and_url_part(@state.uuid, params[:city_id].downcase)
	    @city = City.find(:first, :conditions => { :category_id => city_category.id })
	end
    end

    # Finds the place associated with the request (if any)
    def find_place
	if params[:country_id] && params[:state_id] && params[:city_id] && params[:place_id] && params[:place_id].length > 0
	    @place = Place.find(:first, :conditions => ["url_part = ? OR uuid = ?", params[:place_id], params[:place_id]])
	end
    end
		
    # Finds the calendar associated with the request
    def find_calendar
	if @place.nil?
	    # We need to get the city's calendar.
	    @calendar = @city.calendar
	else
	    @calendar = @place.calendar
	end
    end

    # Finds the event associated with the request (if any)
    def find_event
	if params[:id] && params[:id].length > 0
	    @event = Event.find(:first, :conditions => ["url_part = ? OR uuid = ?", params[:id], params[:id]])
	end
    end
end

