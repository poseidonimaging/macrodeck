class FacebookSearchController < ApplicationController
	def search
		get_networks
		get_home_city
		get_secondary_city

		if !params[:country].nil? && !params[:state].nil? && !params[:city].nil?
			if params[:query]
				# render search results
			else
				# render search form
			end
		end
	end
end
