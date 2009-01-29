class FacebookSearchController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	before_filter :setup_breadcrumbs

	layout "facebook_search"

	def search
		get_networks
		get_home_city
		get_secondary_city

		params[:page] = 1 if params[:page].nil?

		if !params[:uuid].nil?
			@object = DataObject.find_by_uuid(params[:uuid])
			populate_params_with_location_information(@object)

			if params[:query]
				# render search results
				@query = "#{params[:query]}"
				
				# Set up filters
				if !params[:type].nil?
					filter_hash = { "category_id" => @object.category_id.to_i, "type" => params[:type] }
				else
					filter_hash = { "category_id" => @object.category_id.to_i }
				end

				@search = Ultrasphinx::Search.new(
					:filters => filter_hash,
					:query => @query,
					:sort_mode => "relevance",
					:page => params[:page],
					:per_page => 10
				)
				@search.excerpt
			else
				# render search form
			end
		end
	end

	private
		# Set the basecrumbs for this controller.
		def setup_breadcrumbs
				@baseurl = "#{PLACES_FBURL}/search/"
				@basecrumb = Breadcrumb.new("Search", @baseurl)
				@places_basecrumb = Breadcrumb.new("Browse", "#{PLACES_FBURL}/browse/")
		end

		def populate_params_with_location_information(searchroot)
			if searchroot[:type] == "City"
				params[:place] = nil
				params[:city] = searchroot.url_part
				params[:state] = searchroot.category.parent.url_part
				params[:country] = searchroot.category.parent.parent.url_part
			end
		end
end
