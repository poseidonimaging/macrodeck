# This controller does all of the magic for localities.
class LocalitiesController < ApplicationController
    layout :select_layout
    before_filter :find_country
    before_filter :find_region
    before_filter :find_locality

    # List cities
    def index
	startkey = @region.path.dup.push(0)
	endkey = @region.path.dup.push({})

	@localities = Locality.view("by_path_and_type_alpha", :reduce => false, :startkey => startkey, :endkey => endkey)
	@page_title = @region.title
	@back_button = [@country.title, country_regions_path(params[:country_id])]

	respond_to do |format|
	    format.html # index.html.erb
	end
    end

    # This is the "main page" for a city.
    def show
	if @locality.nil?
	    render_404
	else
	    @start_item = params[:start_item].nil? ? 0 : params[:start_item].to_i
	    @page_title = "#{@locality.title}"
	    @back_button = [@region.title, country_region_localities_path(params[:country_id], params[:region_id])]
	    @button = ["Happenings", "#"]
	    startkey = @locality.path.dup.push(0)
	    endkey = @locality.path.dup.push({})
	    @places = Place.view("by_path_and_type_without_neighborhood_alpha", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)

	    respond_to do |format|
		format.html
	    end
	end
    end

    private
	# Finds the country associated with the request.
	def find_country
	    @country = Country.get(params[:country_id]) unless params[:country_id].nil?
	end

	# Finds the region associated with the request.
	def find_region
	    @region = Region.get(params[:region_id]) unless params[:region_id].nil?
	end

	# Finds the city associated with the request
	def find_locality
	    if @country && @region && !params[:id].nil?
		@locality = Locality.get(params[:id])
	    end
	end
end

