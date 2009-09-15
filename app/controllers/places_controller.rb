# This is a resource for a place.
class PlacesController < ApplicationController
	layout 'default'

	# List places
	def index
		
	end

	# Show a place
	def show
		puts "id is: '#{params[:id]}'"
	end

	# Show the HTML to create a place
	def new
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
	end
end
