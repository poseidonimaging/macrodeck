class BlogController < ApplicationController
	layout "default"
	
	def index
		if @params[:groupname] != nil
			uuid = UserService.lookupGroupName(@params[:groupname].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "group"
				@name = @params[:groupname].downcase
				@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
				@posts = BlogService.getBlogPosts(uuid)
			end
		elsif @params[:username] != nil
			uuid = UserService.lookupUserName(@params[:username].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "user"
				@name = @params[:username].downcase
				@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
				@posts = BlogService.getBlogPosts(uuid)
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end
	
	def edit
		if request.method == :get
			if @params[:groupname] != nil
				uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@type = "group"
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
					if @user_loggedin == true
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postmetadata = BlogService.getPostMetadata(@params[:uuid])
							@postuuid = @params[:uuid]
							render :template => "blog/edit"
						end
					else
						render :template => "errors/access_denied"
					end
				end
			elsif @params[:username] != nil
				uuid = UserService.lookupUserName(@params[:username].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@type = "user"
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
					if @user_loggedin == true
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postmetadata = BlogService.getPostMetadata(@params[:uuid])
							@postuuid = @params[:uuid]
							render :template => "blog/edit"
						end
					else
						render :template => "errors/access_denied"
					end
				end
			else
				render :template => "errors/invalid_user_or_group"
			end
		elsif request.method == :post
			if @params[:groupname] != nil
				@uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				@type = "group"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else				
					# Any user can post on any blog. Solution until permissions are completed.
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if @user_loggedin == true
						# Validate the fields
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							if @params[:title].length > 0 && @params[:content].length > 0
								BlogService.editBlogPost(@params[:uuid], @params[:title], @params[:description], @params[:content], nil, nil)
								redirect_to "/#{@type}/#{@name}/blog"
							else
								if @params[:title].length == 0
									@error = "Please enter a title for your blog."
								else
									@error = "Please enter content for your blog."
								end
								@postuuid = @params[:uuid]
								@postmetadata = BlogService.getPostMetadata(@params[:uuid])
								render :template => "blog/edit"
							end
						end
					else
						render :template => "errors/access_denied"
					end
				end
			elsif @params[:username] != nil
				@uuid = UserService.lookupUserName(@params[:username].downcase)
				@type = "user"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					# Any user can post on any blog. Solution until permissions are completed.				
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if @user_loggedin == true
						# Validate the fields
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							if @params[:title].length > 0 && @params[:content].length > 0
								BlogService.editBlogPost(@params[:uuid], @params[:title], @params[:description], @params[:content], nil, nil)
								redirect_to "/#{@type}/#{@name}/blog"
							else
								if @params[:title].length == 0
									@error = "Please enter a title for your blog."
								else
									@error = "Please enter content for your blog."
								end
								@postuuid = @params[:uuid]
								@postmetadata = BlogService.getPostMetadata(@params[:uuid])
								render :template => "blog/edit"
							end
						end
					else
						render :template => "errors/access_denied"
					end
				end
			else
				render :template => "errors/invalid_user_or_group"
			end		
		else
			raise "Unrecognized HTTP request method in blog/edit"
		end
	end
	
	def post
		if request.method == :get
			if @params[:groupname] != nil
				@uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				@type = "group"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					# Any user can post on any blog. Solution until permissions are completed.
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if @user_loggedin == true
						render :template => "blog/post"
					else
						render :template => "errors/access_denied"
					end			
				end
			elsif @params[:username] != nil
				@uuid = UserService.lookupUserName(@params[:username].downcase)
				@type = "user"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					# Any user can post on any blog. Solution until permissions are completed.				
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if @user_loggedin == true
						render :template => "blog/post"
					else
						render :template => "errors/access_denied"
					end
				end
			else
				render :template => "errors/invalid_user_or_group"
			end
		elsif request.method == :post
			if @params[:groupname] != nil
				@uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				@type = "group"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					# Any user can post on any blog. Solution until permissions are completed.
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if @user_loggedin == true
						# Validate the fields
						if @params[:title].length > 0 && @params[:content].length > 0
							# createBlogPost(blogID, creator, postTitle, postDescription, postContent, readPermissions, writePermissions)
							BlogService.createBlogPost(BlogService.getBlogUUID(@uuid), session[:uuid], @params[:title], @params[:description], @params[:content], nil, nil)
							redirect_to "/#{@type}/#{@name}/blog"
						else
							if @params[:title].length == 0
								@error = "Please enter a title for your blog."
							else
								@error = "Please enter content for your blog."
							end
							render :template => "blog/post"
						end
					else
						render :template => "errors/access_denied"
					end			
				end
			elsif @params[:username] != nil
				@uuid = UserService.lookupUserName(@params[:username].downcase)
				@type = "user"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					# Any user can post on any blog. Solution until permissions are completed.				
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if @user_loggedin == true
						# Validate the fields
						if @params[:title].length > 0 && @params[:content].length > 0
							# createBlogPost(blogID, creator, postTitle, postDescription, postContent, readPermissions, writePermissions)
							BlogService.createBlogPost(BlogService.getBlogUUID(@uuid), session[:uuid], @params[:title], @params[:description], @params[:content], nil, nil)
							redirect_to "/#{@type}/#{@name}/blog"
						else
							if @params[:title].length == 0
								@error = "Please enter a title for your blog."
							else
								@error = "Please enter content for your blog."
							end
							render :template => "blog/post"
						end						
					else
						render :template => "errors/access_denied"
					end
				end
			else
				render :template => "errors/invalid_user_or_group"
			end		
		end
	end
end
