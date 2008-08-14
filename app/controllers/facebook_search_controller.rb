class FacebookSearchController < ApplicationController
	before_filter :require_facebook_login
	before_filter :initialize_facebook_user
	before_filter :setup_breadcrumbs

	layout "facebook_search"

	def search
		get_networks
		get_home_city
		get_secondary_city
		fb_sig_cleanup

		params[:page] = 1 if params[:page].nil?

		if !params[:uuid].nil?
			@object = DataObject.find_by_uuid(params[:uuid])
			p @object
			if params[:query]
				# render search results
				@query = "#{params[:query]}"
				@search = Ultrasphinx::Search.new(
					:filters => { "category_id" => @object.category_id.to_i },
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
end
