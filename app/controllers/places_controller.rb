# This is a resource for a place.
class PlacesController < ApplicationController
    layout 'default'
    before_filter :find_country
    before_filter :find_region
    before_filter :find_locality
    before_filter :find_place

    # List places
    def index
	@places = @city.places
		
	respond_to do |format|
	    format.html # index.html.erb
	end
    end

    # Show a place
    def show
	if @place.nil?
	    raise ActiveRecord::RecordNotFound
	else
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
