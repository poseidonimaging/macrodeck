class BlogController < ApplicationController
	layout "default"
	
	def index
		if @params[:groupname] != nil
			uuid = UserService.lookupGroupName(@params[:groupname].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
				@posts = BlogService.getBlogPosts(uuid)
			end
		elsif @params[:username] != nil
			uuid = UserService.lookupUserName(@params[:username].downcase)
			if uuid == nil
				render :template "errors/invalid_user_or_group"
			else
				@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
				@posts = BlogService.getBlogPosts(uuid)
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end
end
