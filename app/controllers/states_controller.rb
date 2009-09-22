# This controller maps state categories to real states.
# A state is a category whose parent is a country
# Really this is a stub because the interface for categories behaves differently.
class StatesController < ApplicationController
	layout 'default'

	# List states
	def index
		@country = Category.find_by_parent_uuid_and_url_part(Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid, params[:country_id].downcase)
		@states = @country.children
	end

	# Show a state's cities
	def show
		@country = Category.find_by_parent_uuid_and_url_part(Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid, params[:country_id].downcase)
		@state = Category.find_by_parent_uuid_and_url_part(@country.uuid, params[:id].downcase)
		@cities = @state.children
	end
end
