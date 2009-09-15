# This controller maps country categories to real countries.
# A country is a category whose immediate parent is "MacroDeck Places".
# Really this is a stub because the interface for categories behaves differently.
class CountriesController < ApplicationController
	layout 'default'

	# List countries
	def index
		@countries = Category.find(:all, :conditions => ["parent_uuid = ?", Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid])
	end

	# Show a country's states...
	def show
		@country = Category.find_by_parent_uuid_and_url_part(Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid, params[:id])
		@states = @country.children
	end
end
