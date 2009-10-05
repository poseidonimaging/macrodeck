# This controller does all of the magic for cities.
class CitiesController < ApplicationController
	layout 'default'
	before_filter :find_country
	before_filter :find_state
	before_filter :find_city

	# List cities
	def index
		@cities = @state.children

		respond_to do |format|
			format.html # index.html.erb 
		end
	end

	# This is the "main page" for a city.
	def show
		respond_to do |format|
			format.html
			format.xml { render :xml => @city }
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

		# Finds the city associated with the request (and its associated metainformation)
		def find_city
			if params[:country_id] && params[:state_id] && params[:id]
				# Walk the tree 
				city_category = Category.find_by_parent_uuid_and_url_part(@state.uuid, params[:id].downcase)
				@city = City.find(:first, :conditions => { :category_id => city_category.id })
				@events = Event.find(:all, :conditions => { :category_id => city_category.id })
			end
		end
end

