# This controller does all of the magic for events
class EventsController < ApplicationController
    layout 'mobile'
    before_filter :find_country
    before_filter :find_region
    before_filter :find_locality
    before_filter :find_place
    before_filter :find_event

    # List events
    def index
	@start_item = params[:start_item].nil? ? 0 : params[:start_item].to_i
	@page_title = @locality.title
	@page_title_long = "#{@locality.title} Happenings"
	@button = ["Places", country_region_locality_places_path(@country.id, @region.id, @locality.id)]

	earliest_event_end_time = Time.new
	
	nstartkey = @locality.path.dup.push(0)
	nendkey = @locality.path.dup.push({})
	hood_ids = Event.view("by_path", :reduce => true, :group => true, :group_level => 4, :startkey => nstartkey, :endkey => nendkey)["rows"].collect do |event|
	    [event["key"][-1], event["value"]]
	end
	@neighborhoods = []
	hood_ids.each do |hood_id|
	    hood = Neighborhood.get(hood_id[0])
	    @neighborhoods << [hood["title"], hood_id[0], hood_id[1]] unless hood.nil?
	end
	@neighborhoods.sort!
	@event_types = Event.view("by_event_type", :reduce => true, :group => true, :group_level => 4, :startkey => nstartkey, :endkey => nendkey)["rows"]

	if !params[:q].nil?
	    @page_title_log = "#{@locality.title} > Happenings > Search"
	    query = "path:#{@locality.path.join("/")}/* AND (#{query_to_boolean_and(params[:q])})"
	    event_search = Event.search("common_fields", query, :limit => 10, :skip => @start_item, :sort => "/start_time<date>")
	    @events = event_search["rows"]
	    @events_count = event_search["rows"].length == 0 ? 0 : event_search["total_rows"]
	    @back_button = [@locality.title, country_region_locality_events_path(@country.id, @region.id, @locality.id)]
	elsif params[:event_type].nil? && !params[:neighborhood].nil?
	    @page_title_long = "#{@locality.title} Happenings > #{Neighborhood.get(params[:neighborhood]).title}"

	    startkey = @locality.path.dup.push(params[:neighborhood]).push(earliest_event_end_time.getutc.iso8601)
	    endkey = @locality.path.dup.push(params[:neighborhood]).push({})
	    @events = Event.view("by_path_without_place_with_end_time", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
	    count_query = Event.view("by_path_without_place_with_end_time", :reduce => true, :group => true, :group_level => 4, :startkey => startkey, :endkey => endkey)
	    @events_count = count_query["rows"].length == 0 ? 0 : count_query["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_events_path(params[:country_id], params[:region_id], params[:id])]
	elsif !params[:event_type].nil? && params[:neighborhood].nil?
	    @page_title_long = "#{@locality.title} Happenings > #{params[:event_type]}"

	    startkey = @locality.path.dup.push(params[:event_type]).push(0)
	    endkey = @locality.path.dup.push(params[:event_type]).push({})
	    @events = Event.view("by_event_type_alpha", :reduce => false, :startkey => startkey, :endkey => endkey)
	    count_query = Event.view("by_event_type_alpha", :reduce => true, :startkey => startkey, :endkey => endkey)
	    @events_count = count_query["rows"].length == 0 ? 0 : count_query["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_events_path(params[:country_id], params[:region_id], params[:id])]
	elsif !params[:event_type].nil? && !params[:neighborhood].nil?
	    @page_title_long = "#{@locality.title} Happenings > #{Neighborhood.get(params[:neighborhood]).title} > #{params[:event_type]}"

	    startkey = @locality.path.dup.push(params[:neighborhood]).push(params[:event_type]).push(0)
	    endkey = @locality.path.dup.push(params[:neighborhood]).push(params[:event_type]).push({})
	    @events = Event.view("by_event_type_alpha", :reduce => false, :startkey => startkey, :endkey => endkey)
	    count_query = Event.view("by_event_type_alpha", :reduce => true, :startkey => startkey, :endkey => endkey)
	    @events_count = count_query["rows"].length == 0 ? 0 : count_query["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_events_path(params[:country_id], params[:region_id], params[:id])]
	elsif params[:event_type].nil? && params[:neighborhood].nil?
	    startkey = @locality.path.dup.push(earliest_event_end_time.getutc.iso8601)
	    endkey = @locality.path.dup.push({})
	    @events = Event.view("by_path_without_place_or_neighborhood_with_end_time", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
	    begin
		@events_count = Event.view("by_path_without_place_or_neighborhood_with_end_time", :reduce => true, :startkey => startkey, :endkey => endkey)["rows"][0]["value"]
	    rescue
		@events_count = 0
	    end
	    #@back_button = [@region.title, country_region_localities_path(@country.id, @region.id)]
	    unless @start_item == 0
		@back_button = [@locality.title, country_region_locality_events_path(@country.id, @region.id, @locality.id)]
	    end
	end
	respond_to do |format|
	    format.html # index.html.erb
	end
    end

    # Shows an event.
    def show
        @page_title = ""
	@page_title_long = "#{@locality.title} > #{@event.title}"
	@back_button = [@locality.title, country_region_locality_events_path(params[:country_id], params[:region_id], params[:locality_id], :event_type => params[:event_type], :neighborhood => params[:neighborhood])]
	place_query = Place.view("by_path", :reduce => false, :startkey => @event.parent, :limit => 1)
	if place_query.nil? || place_query.length != 1
	    @place = nil
	else
	    @place = place_query[0]
	end

	nstartkey = @locality.path.dup.push(0)
	nendkey = @locality.path.dup.push({})
	hood_ids = Event.view("by_path", :reduce => true, :group => true, :group_level => 4, :startkey => nstartkey, :endkey => nendkey)["rows"].collect do |event|
	    [event["key"][-1], event["value"]]
	end
	@neighborhoods = []
	hood_ids.each do |hood_id|
	    hood = Neighborhood.get(hood_id[0])
	    @neighborhoods << [hood["title"], hood_id[0], hood_id[1]] unless hood.nil?
	end
	@neighborhoods.sort!
	@event_types = Event.view("by_event_type", :reduce => true, :group => true, :group_level => 4, :startkey => nstartkey, :endkey => nendkey)["rows"]
    end

    # Renders the HTML to create an event.
    def new
	@desktop_override = true
	startkey = @locality.path.dup.push(0)
	endkey = @locality.path.dup.push({})
	@places = Place.view("by_path_without_neighborhood_alpha", :reduce => false, :startkey => startkey, :endkey => endkey)
	@event = Event.new

	respond_to do |format|
	    format.html do
		render :layout => "restlessnapkin" # new.html.erb
	    end
	end
    end

    # Renders the HTML to edit an event.
    def edit
	@desktop_override = true

	respond_to do |format|
	    format.html do
		render :layout => "restlessnapkin" # new.html.erb
	    end
	end
    end

    # Saves an event.
    def create
	@desktop_override = true
	@place = Place.get(nilify(params[:event][:place_id]))
	id = Guid.new
	path = @place.path.dup.push(id.to_s)
	@event = Event.new
	@event["_id"] = id.to_s
	@event.path = path
	@event.title = nilify(params[:event][:title])
	@event.description = nilify(params[:event][:description])
	@event.start_time = nilify(params[:event][:start_time]).nil? ? nil : Time.parse(nilify(params[:event][:start_time])).getutc.iso8601
	@event.end_time = nilify(params[:event][:end_time]).nil? ? nil : Time.parse(nilify(params[:event][:end_time])).getutc.iso8601
	@event.recurrence = nilify(params[:event][:recurrence])
	@event.event_type = nilify(params[:event][:event_type])
	@event.created_by = "RestNapForm"
	@event.updated_by = "RestNapForm"
	@event.owned_by = "RestNapForm"

	if @event.valid?
	    @event.save
	    #redirect_to country_region_locality_event_path(@country, @region, @locality, @event)
	    redirect_to country_region_locality_place_path(@country, @region, @locality, @place)
	else
	    startkey = @locality.path.dup.push(0)
	    endkey = @locality.path.dup.push({})
	    @places = Place.view("by_path_without_neighborhood_alpha", :reduce => false, :startkey => startkey, :endkey => endkey)
	    @errors = true
	    respond_to do |format|
		format.html do
		    render :layout => "restlessnapkin", :action => :new
		end
	    end
	end
    end

    # Saves an updated event.
    def update
	@desktop_override = true
	@event.title = nilify(params[:event][:title])
	@event.description = nilify(params[:event][:description])
	@event.start_time = nilify(params[:event][:start_time]).nil? ? nil : Time.parse(nilify(params[:event][:start_time])).getutc.iso8601
	@event.end_time = nilify(params[:event][:end_time]).nil? ? nil : Time.parse(nilify(params[:event][:end_time])).getutc.iso8601
	@event.recurrence = nilify(params[:event][:recurrence])
	@event.event_type = nilify(params[:event][:event_type])
	@event.updated_by = "RestNapForm"

	if @event.valid?
	    @event.save
	    #redirect_to country_region_locality_event_path(@country, @region, @locality, @event)
	    redirect_to country_region_locality_events_path(@country, @region, @locality)
	else
	    @errors = true
	    respond_to do |format|
		format.html do
		    render :layout => "restlessnapkin", :action => :edit
		end
	    end
	end
    end

    # Deletes a happening.
    def destroy
	@event.destroy
	redirect_to country_region_locality_events_path(@country.id, @region.id, @locality.id)
    end

    private
 	# Finds the country associated with the request.
	def find_country
	    @country = Country.get(params[:country_id])
	end

	# Finds the region associated with the request.
	def find_region
	    @region = Region.get(params[:region_id])
	end

	# Finds the locality associated with the request
	def find_locality
	    @locality = Locality.get(params[:locality_id])
	end

	# Finds the place associated with the request.
	def find_place
	    @place = Place.get(params[:place_id]) unless params[:place_id].nil?
	end

	# Finds the event associated with the request.
	def find_event
	    @event = Event.get(params[:id]) unless params[:id].nil?
	end
end

