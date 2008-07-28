class FacebookSearchController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	before_filter :setup_breadcrumbs

	layout "facebook_search"

	def search
		get_networks
		get_home_city
		get_secondary_city

		if !params[:uuid].nil?
			@object = DataObject.find_by_uuid(params[:uuid])
			if params[:query]
				# render search results
				@query = "#{params[:query]}"
				@search = Ultrasphinx::Search.new(
					:query => @query,
					:sort_mode => "relevance",
					:filters => { "parent_id" => @object.id },
					:page => params[:page],
					:per_page => 30
				)
				@search.excerpt
			else
				# render search form
			end
		end
	end
end
