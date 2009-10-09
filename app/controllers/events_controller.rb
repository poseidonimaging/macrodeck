# This controller does all of the magic for events
class EventsController < ApplicationController
	layout 'default'
	before_filter :find_country
	before_filter :find_state
	before_filter :find_city
	before_filter :find_place
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

		# Finds the event associated with the request (if any)
		def find_event
			if params[:id] && params[:id].length > 0
				@event = Event.find(:first, :conditions => ["url_part = ? OR uuid = ?", params[:id], params[:id]])
			end
		end
end

