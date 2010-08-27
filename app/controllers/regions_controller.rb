# Pulls regions.
class RegionsController < ApplicationController
	layout :select_layout

	# List states
	def index
		@country = Country.get(params[:country_id])
		startkey = @country.path.dup.push(0)
		endkey = @country.path.dup.push({})
		@regions = Region.view("by_path_alpha", :reduce => false, :startkey => startkey, :endkey => endkey)
		@page_title = @country.title
		@back_button = ["Countries", countries_path]
	end

	# Show a state's cities
	def show
		redirect_to country_region_localities_path(params[:country_id], params[:id])
	end
end
