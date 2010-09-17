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

