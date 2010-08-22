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
	redirect_to country_region_locality_places_path(@country.id, @region.id, @locality.id)
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

