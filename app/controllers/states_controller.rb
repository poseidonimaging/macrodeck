# This controller maps state categories to real states.
# A state is a category whose parent is a country
# Really this is a stub because the interface for categories behaves differently.
class StatesController < ApplicationController
	layout 'restlessnapkin'

	# List states
	def index
		@page_title = "#{@country.name} > States"
		@country = Category.find_by_parent_uuid_and_url_part(Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid, params[:country_id].downcase)
		@states = @country.children
	end

	# Show a state's cities
	def show
		redirect_to country_state_cities_path(params[:country_id], params[:id])
	end
end
