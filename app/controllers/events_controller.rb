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

	if params[:event_type].nil? && params[:neighborhood].nil?
	    earliest_event_time = Time.new - 6.hours
	    startkey = @locality.path.dup.push(earliest_event_time.getutc.iso8601)
	    endkey = @locality.path.dup.push({})
	    @events = Event.view("by_path_without_place_or_neighborhood_with_time", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
	    begin
		@events_count = Event.view("by_path_without_place_or_neighborhood_with_time", :reduce => true, :startkey => startkey, :endkey => endkey)["rows"][0]["value"]
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
	@event.start_time = nilify(params[:event][:start_time])
	@event.end_time = nilify(params[:event][:end_time])
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

