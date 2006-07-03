class TestController < ApplicationController
	layout "default"
	def start_service
		Services.startService @params[:service]
		redirect_to :action => "show_loaded_services"
	end
	def show_loaded_services
		@services = Services.getLoadedServices
	end
	def create_blog
		if request.method == :post
			# We handle creating a blog here.
			BlogService.createBlog(@params[:blogname], @params[:blogdescription], CREATOR_MACRODECK, @params[:blogowner])
			redirect_to :action => "index"
		end
	end
	def create_blog_post
		if request.method == :post
			# We handle creating a blog post here.
			BlogService.createBlogPost(BLOG_MACRODECK, @params[:postas], @params[:posttitle], @params[:postdescription], @params[:postcontent], nil, nil)
			redirect_to :action => "index"
		end
	end
end
