# This is a resource for a place.
class PlacesController < ApplicationController
    layout 'mobile'
    before_filter :find_country
    before_filter :find_region
    before_filter :find_locality
    before_filter :find_place

    # List places
    def index
	@start_item = params[:start_item].nil? ? 0 : params[:start_item].to_i
	@page_title = @locality.title
	@page_title_long = "#{@locality.title} Places"
	@button = ["Happenings", country_region_locality_events_path(@country.id, @region.id, @locality.id)]
	if @start_item > 0
	    @back_button = [@locality.title, country_region_locality_places_path(params[:country_id], params[:region_id], params[:id])]
	end
	if params[:fare].nil? && params[:neighborhood].nil?
	    startkey = @locality.path.dup.push(0)
	    endkey = @locality.path.dup.push({})
	    @places = Place.view("by_path_without_neighborhood_alpha", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
	    @places_count = Place.view("by_path_without_neighborhood_alpha", :reduce => true, :startkey => startkey, :endkey => endkey)["rows"][0]["value"]
	    #@back_button = [@region.title, country_region_localities_path(params[:country_id], params[:region_id])]
	elsif params[:fare].nil? && !params[:neighborhood].nil?
	    startkey = @locality.path.dup.push(params[:neighborhood]).push(0)
	    endkey = @locality.path.dup.push(params[:neighborhood]).push({})
	    @places = Place.view("by_path_alpha", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
	    @places_count = Place.view("by_path_alpha", :reduce => true, :startkey => startkey, :endkey => endkey)["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_places_path(params[:country_id], params[:region_id], params[:id])]
	elsif !params[:fare].nil? && params[:neighborhood].nil?
	    startkey = @locality.path.dup.push(params[:fare]).push(0)
	    endkey = @locality.path.dup.push(params[:fare]).push({})
	    @places = Place.view("by_fare_alpha", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
	    @places_count = Place.view("by_fare_alpha", :reduce => true, :startkey => startkey, :endkey => endkey)["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_places_path(params[:country_id], params[:region_id], params[:id])]
	elsif !params[:fare].nil? && !params[:neighborhood].nil?
	    startkey = @locality.path.dup.push(params[:neighborhood]).push(params[:fare]).push(0)
	    endkey = @locality.path.dup.push(params[:neighborhood]).push(params[:fare]).push({})
	    @places = Place.view("by_fare_alpha", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
	    @places_count = Place.view("by_fare_alpha", :reduce => true, :startkey => startkey, :endkey => endkey)["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_places_path(params[:country_id], params[:region_id], params[:id])]
	end

	respond_to do |format|
	    format.html
	end
    end

    # Show a place
    def show
	if @place.nil?
	    raise ActiveRecord::RecordNotFound
	else
	    @page_title = ""
	    @back_button = [@locality.title, country_region_locality_places_path(params[:country_id], params[:region_id], params[:locality_id], :fare => params[:fare], :neighborhood => params[:neighborhood])]

	    # Get events for this place.
	    earliest_event_time = Time.new - 6.hours
	    startkey = @place.path.dup.push(earliest_event_time.getutc.iso8601)
	    endkey = @place.path.dup.push({})
	    @events = Event.view("by_path_and_start_time", :reduce => false, :startkey => startkey, :endkey => endkey)
	    respond_to do |format|
		format.html # show.html.erb
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
	    @place = Place.get(params[:id]) unless params[:id].nil?
	end
end
