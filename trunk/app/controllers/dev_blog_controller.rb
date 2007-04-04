class DevBlogController < ApplicationController
	layout "default"
	def index
		@posts = BlogService.getBlogPosts(GROUP_MACRODECK)
	end
end
