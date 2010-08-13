# Pulls regions.
class RegionsController < ApplicationController
	layout :select_layout

	# List states
	def index
		@country = Country.get(params[:country_id])
		startkey = @country.path.dup.push(0)
		@regions = Region.view("by_path_and_type", :reduce => false, :startkey => startkey)
		@page_title = "#{@country.title} > States"
	end

	# Show a state's cities
	def show
		redirect_to country_region_localities_path(params[:country_id], params[:id])
	end
end
