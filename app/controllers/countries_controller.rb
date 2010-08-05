# This controller pulls countries from CouchDB.
class CountriesController < ApplicationController
	layout 'restlessnapkin'

	# List countries
	def index
		@page_title = "Countries"
		@countries = Country.view("by_title") 
	end

	# Show a country's states/regions...
	def show
		redirect_to country_regions_path(params[:id])
	end
end
