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
	if !@locality.nil? && @place.nil?
	    startkey = @locality.path.dup.push(0)
	    endkey = @locality.path.dup.push({})
	    @events = Event.view("by_path_alpha", :reduce => false, :startkey => startkey, :endkey => endkey, :limit => 10, :skip => @start_item)
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

