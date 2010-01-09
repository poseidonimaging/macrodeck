# This controller handles Wall objects. There is no edit/update/new/create
# functionality on this controller because walls are system-generated.
class WallsController < ApplicationController
	layout 'default'
	before_filter :find_country
	before_filter :find_state
	before_filter :find_city
	before_filter :find_place		# may not be used; only if a wall exists on a place.
	before_filter :find_calendar	# may not be used; only if a wall exists on a calendar.
	before_filter :find_event		# may not be used; only if a wall exists on an event.
	before_filter :find_wall

	# List all walls. This will not be used when this is a singular resource.
	def index
		@walls = Wall.find(:all)

		respond_to do |format|
			format.html # index.html.erb 
		end
	end

	# This shows a wall.
	def show
		respond_to do |format|
			format.html # show.html.erb
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
		
		# Finds the calendar associated with the request
		def find_calendar
			if @place.nil?
				# We need to get the city's calendar.
				@calendar = @city.calendar
			else
				@calendar = @place.calendar
			end
		end

		# Finds the event associated with the request (if any)
		def find_event
			if params[:event_id] && params[:event_id].length > 0
				@event = Event.find(:first, :conditions => ["url_part = ? OR uuid = ?", params[:event_id], params[:event_id]])
			end
		end
		
		# Finds the wall associated with the request
		def find_wall
			[@calendar, @event, @city, @place].each do |parent|
				@wall = parent.wall if !parent.nil? && parent.respond_to?(:wall)
			end
		end
end

