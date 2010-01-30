# This controller maps country categories to real countries.
# A country is a category whose immediate parent is "MacroDeck Places".
# Really this is a stub because the interface for categories behaves differently.
class CountriesController < ApplicationController
	layout 'restlessnapkin'

	# List countries
	def index
		@page_title = "Countries"
		@countries = Category.find(:all, :conditions => ["parent_uuid = ?", Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid])
	end

	# Show a country's states...
	def show
		redirect_to country_states_path(params[:id])
	end
end
