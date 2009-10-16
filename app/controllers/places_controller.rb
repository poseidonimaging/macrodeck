# This is a resource for a place.
class PlacesController < ApplicationController
	layout 'default'
	before_filter :find_country
	before_filter :find_state
	before_filter :find_city
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

	# Show the HTML to create a place
	def new
		@place = Place.new # TODO: something like @city.place.new ?
		respond_to do |format|
			format.html # new.html.erb
		end
	end

	# Actually create the place
	def create
		
	end

	# Show the HTML to edit a place.
	def edit
	end

	# Actually update a place
	def update
	end

	# Delete a place.
	def destroy
		@place.destroy
		flash[:success] = "#{@place.name} deleted successfully."
		redirect_to country_state_city_places_path(params[:country_id], params[:state_id], params[:city_id])
	end

	private
                # Finds the country associated with the request.
                def find_country
                        @country = Category.find_by_parent_uuid_and_url_part(Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid, params[:country_id].downcase) if
 params[:country_id]
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
                                @city = City.find(:first, :conditions => { :category_id => city_category.id }) if city_category
                        end
                end
		
		# Finds the place associated with the request.
		def find_place
			if params[:id] && !@city.nil?
				@place = Place.find(:first, :conditions => ["(uuid = ? OR url_part = ?) AND parent_id = ?", params[:id], params[:id], @city.id])
			elsif params[:id] && @city.nil?
				@place = Place.find_by_uuid(params[:id])
			end
		end
end
