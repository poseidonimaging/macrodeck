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
		if @city.nil?
			raise ActiveRecord::RecordNotFound
		else
			@page_title = "#{@city.name}, #{@state.name}"
			respond_to do |format|
				format.html
				format.xml { render :xml => @city }
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
			@back_button = ["States", country_regions_path(params[:country_id])]
		    end
		end
end

