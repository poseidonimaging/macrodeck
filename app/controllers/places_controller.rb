# This is a resource for a place.
class PlacesController < ApplicationController
    layout 'mobile'
    before_filter :find_country
    before_filter :find_region
    before_filter :find_locality
    before_filter :find_place
    before_filter :process_geo

    # List places
    def index
	@start_item = params[:start_item].nil? ? 0 : params[:start_item].to_i
	@page_title = @locality.title
	@page_title_long = "#{@locality.title} Places"
	@button = ["Happenings", country_region_locality_events_path(@country.id, @region.id, @locality.id)]
	if @start_item > 0 || !params[:q].nil?
	    @back_button = [@locality.title, country_region_locality_places_path(params[:country_id], params[:region_id], params[:id])]
	end

	nstartkey = @locality.path.dup.push(0)
	nendkey = @locality.path.dup.push({})
	@neighborhoods = Neighborhood.view("by_path_alpha", :reduce => false, :startkey => nstartkey, :endkey => nendkey)
	@fares = Place.view("by_fare", :reduce => true, :group => true, :group_level => 4, :startkey => nstartkey, :endkey => nendkey)["rows"]

	# Missing foursquare venue ID
	if !params[:unmatched].nil? && current_tab == :tips
	    @page_title_long = "#{@locality.title} > Places > Places Not Matched to Foursquare"
	    @tab_buttons = [
		["Tips", country_region_locality_places_path(@country, @region, @locality, :tab => "tips" ), "pressed"],
		["Search", country_region_locality_places_path(@country, @region, @locality, :tab => "search")],
		["Location", country_region_locality_places_path(@country, @region, @locality, :tab => "location")]
	    ]

	    @places = Place.view("by_missing_foursquare_venue_id", :reduce => false, :limit => 10, :skip => @start_item)
	    count_query = Place.view("by_missing_foursquare_venue_id", :reduce => false, :limit => 0, :include_docs => false)
	    @places_count = count_query["total_rows"]
	# Search.
	elsif !params[:q].nil? || current_tab == :search
	    @page_title_long = "#{@locality.title} > Places > Search"
	    @tab_buttons = [
		["Tips", country_region_locality_places_path(@country, @region, @locality, :tab => "tips" )],
		["Search", country_region_locality_places_path(@country, @region, @locality, :tab => "search"), "pressed"],
		["Location", country_region_locality_places_path(@country, @region, @locality, :tab => "location")]
	    ]

	    if !params[:q].nil?
		query = "path:#{@locality.path.join("/")}/* AND ( #{process_query(params[:q])} )"
		RAILS_DEFAULT_LOGGER.info "Querying: #{query}"
		place_search = Place.search("common_fields", query, :limit => 10, :skip => @start_item)
		@places = place_search["rows"]
		@places_count = place_search["rows"].length == 0 ? 0 : place_search["total_rows"]
	    end
	# Geolocation.
	elsif !params[:geo].nil? || current_tab == :location
	    @page_title_long = "#{@locality.title} > Places > Location"
	    @tab_buttons = [
		["Tips", country_region_locality_places_path(@country, @region, @locality, :tab => "tips" )],
		["Search", country_region_locality_places_path(@country, @region, @locality, :tab => "search")],
		["Location", country_region_locality_places_path(@country, @region, @locality, :tab => "location"), "pressed"]
	    ]

	    if !@lat.nil? && !@lng.nil? && !@radius.nil?
		@places = Place.proximity_search("geocode", @lat, @lng, @radius)
		@places_count = @places.length
	    end
	# Tips.
	elsif params[:fare].nil? && params[:neighborhood].nil?
	    @page_title_long = "#{@locality.title} > Places"
	    @tab_buttons = [
		["Tips", country_region_locality_places_path(@country, @region, @locality, :tab => "tips" ), "pressed"],
		["Search", country_region_locality_places_path(@country, @region, @locality, :tab => "search")],
		["Location", country_region_locality_places_path(@country, @region, @locality, :tab => "location")]
	    ]
	    # commented out because we don't do anything besides Austin yet.
	    #@back_button = [@region.title, country_region_localities_path(params[:country_id], params[:region_id])]

	    startkey = @locality.path.dup.push({})
	    endkey = @locality.path.dup.push(0)
	    @places = Place.view("by_path_without_neighborhood_tips", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item, :descending => true)
	    count_query = Place.view("by_path_without_neighborhood_tips", :reduce => true, :startkey => startkey, :endkey => endkey, :descending => true)
	    @places_count = count_query["rows"].length == 0 ? 0 : count_query["rows"][0]["value"]
	elsif params[:fare].nil? && !params[:neighborhood].nil?
	    @page_title_long = "#{@locality.title} > #{Neighborhood.get(params[:neighborhood]).title}"
	    @tab_buttons = [
		["Tips", country_region_locality_places_path(@country, @region, @locality, :tab => "tips"), "pressed"],
		["Search", country_region_locality_places_path(@country, @region, @locality, :tab => "search")],
		["Location", country_region_locality_places_path(@country, @region, @locality, :tab => "location")]
	    ]

	    startkey = @locality.path.dup.push(params[:neighborhood]).push({})
	    endkey = @locality.path.dup.push(params[:neighborhood]).push(0)
	    @places = Place.view("by_path_and_tips", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item, :descending => true)
	    count_query = Place.view("by_path_and_tips", :reduce => true, :startkey => startkey, :endkey => endkey, :descending => true)
	    @places_count = count_query["rows"].length == 0 ? 0 : count_query["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_places_path(@country, @region, @locality, :tab => "tips")]
	elsif !params[:fare].nil? && params[:neighborhood].nil?
	    @page_title_long = "#{@locality.title} > #{params[:fare]}"
	    @tab_buttons = [
		["Tips", country_region_locality_places_path(@country, @region, @locality, :tab => "tips"), "pressed"],
		["Search", country_region_locality_places_path(@country, @region, @locality, :tab => "search")],
		["Location", country_region_locality_places_path(@country, @region, @locality, :tab => "location")]
	    ]

	    startkey = @locality.path.dup.push(params[:fare]).push({})
	    endkey = @locality.path.dup.push(params[:fare]).push(0)
	    @places = Place.view("by_fare_tips", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item, :descending => true)
	    count_query = Place.view("by_fare_tips", :reduce => true, :startkey => startkey, :endkey => endkey, :descending => true)
	    @places_count = count_query["rows"].length == 0 ? 0 : count_query["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_places_path(@country, @region, @locality, :tab => "tips")]
	elsif !params[:fare].nil? && !params[:neighborhood].nil?
	    @page_title_long = "#{@locality.title} > #{Neighborhood.get(params[:neighborhood]).title} > #{params[:fare]}"
	    @tab_buttons = [
		["Tips", country_region_locality_places_path(@country, @region, @locality, :tab => "tips"), "pressed"],
		["Search", country_region_locality_places_path(@country, @region, @locality, :tab => "search")],
		["Location", country_region_locality_places_path(@country, @region, @locality, :tab => "location")]
	    ]

	    startkey = @locality.path.dup.push(params[:neighborhood]).push(params[:fare]).push({})
	    endkey = @locality.path.dup.push(params[:neighborhood]).push(params[:fare]).push(0)
	    @places = Place.view("by_fare_tips", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item, :descending => true)
	    count_query = Place.view("by_fare_tips", :reduce => true, :startkey => startkey, :endkey => endkey, :descending => true)
	    @places_count = count_query["rows"].length == 0 ? 0 : count_query["rows"][0]["value"]
	    @back_button = [@locality.title, country_region_locality_places_path(@country, @region, @locality, :tab => "tips")]
	end

	respond_to do |format|
	    format.html do
		if request.xhr?
		    render :layout => false
		else
		    render
		end
	    end
	end
    end

    # Show a place
    def show
	if @place.nil?
	    raise ActiveRecord::RecordNotFound
	else
	    @page_title = ""
	    @page_title_long = "#{@locality.title} > #{@place.title}"
	    @back_button = [@locality.title, country_region_locality_places_path(params[:country_id], params[:region_id], params[:locality_id], :fare => params[:fare], :neighborhood => params[:neighborhood], :q => params[:q])]

	    nstartkey = @locality.path.dup.push(0)
	    nendkey = @locality.path.dup.push({})
	    @neighborhoods = Neighborhood.view("by_path_alpha", :reduce => false, :startkey => nstartkey, :endkey => nendkey)
	    @fares = Place.view("by_fare", ActiveSupport::OrderedHash[:reduce, true, :group, true, :group_level, 4, :startkey, nstartkey, :endkey, nendkey])["rows"]

	    # UGLY HACK
	    if params[:foursquare_venue_id]
		@place.foursquare_venue_id = params[:foursquare_venue_id]
		@place.save
	    end

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

	# Gets the lat/lng from the supplied geo.
	def process_geo
	    if !params[:geo].nil? && params[:geo].split(",").length == 2
		@lat = params[:geo].split(",")[0].to_f
		@lng = params[:geo].split(",")[1].to_f
	    end
	    if params[:radius].nil?
		@radius = 1.0
	    else
		@radius = params[:radius].to_f
	    end
	end
end
