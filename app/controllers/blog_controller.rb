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
				@guuid = BlogService.getBlogUUID(uuid)
				@posts = BlogService.getBlogPosts(uuid)
				if uuid == GROUP_MACRODECK
					set_current_tab "devblog"
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
				@guuid = BlogService.getBlogUUID(uuid)				
				@posts = BlogService.getBlogPosts(uuid)

				if @user_username != nil && @name == @user_username.downcase
					set_tabs_for_user(@name, true)
					set_current_tab "blog"
				else
					set_tabs_for_user(@name, false)
					set_current_tab "blog"
				end
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end
	
	def delete
		# for security purposes (i.e. so people don't post images linking to the delete link),
		# you can only actually delete via POST
		if request.method == :get
			if @params[:groupname] != nil
				uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@type = "group"
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
					if DataService.canWrite?(@params[:uuid], @user_uuid)
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postmetadata = BlogService.getPostMetadata(@params[:uuid])
							@postuuid = @params[:uuid]
							render :template => "blog/delete"
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
					if DataService.canWrite?(@params[:uuid], @user_uuid)
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postmetadata = BlogService.getPostMetadata(@params[:uuid])
							@postuuid = @params[:uuid]
							render :template => "blog/delete"
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
				uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@type = "group"
					@name = @params[:groupname].downcase
					if DataService.canWrite?(@params[:uuid], @user_uuid)
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postuuid = @params[:uuid]
							BlogService.deleteBlogPost(@postuuid)
							redirect_to "/#{@type}/#{@name}/blog"
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
					if DataService.canWrite?(@params[:uuid], @user_uuid)
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postuuid = @params[:uuid]
							BlogService.deleteBlogPost(@postuuid)
							redirect_to "/#{@type}/#{@name}/blog"
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
					if DataService.canWrite?(@params[:uuid], @user_uuid)
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
					if DataService.canWrite?(@params[:uuid], @user_uuid)
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
					if DataService.canWrite?(@params[:uuid], @user_uuid)
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
					if DataService.canWrite?(@params[:uuid], @user_uuid)
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
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					@readperms = DataService.getDefaultPermissions(BlogService.getBlogUUID(@uuid), :read)
					@writeperms = DataService.getDefaultPermissions(BlogService.getBlogUUID(@uuid), :write)
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
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
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					@readperms = DataService.getDefaultPermissions(BlogService.getBlogUUID(@uuid), :read)
					@writeperms = DataService.getDefaultPermissions(BlogService.getBlogUUID(@uuid), :write)					
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
						render :template => "blog/post"
					else
						render :template => "errors/access_denied"
					end
				end
			else
				render :template => "errors/invalid_user_or_group"
			end
		elsif request.method == :post
			PermissionController.parse_permissions(@params[:write])
			if @params[:groupname] != nil
				@uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				@type = "group"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
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
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
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

	def view
		if request.method == :get
			if @params[:groupname] != nil
				uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@type = "group"
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(uuid))
					if DataService.canRead?(@params[:uuid], @user_uuid)
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postmetadata = BlogService.getPostMetadata(@params[:uuid])
							@postuuid = @params[:uuid]
							@comments = BlogService.getBlogComments(@params[:uuid])
							render :template => "blog/view"
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
					if DataService.canRead?(@params[:uuid], @user_uuid)
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postmetadata = BlogService.getPostMetadata(@params[:uuid])
							@postuuid = @params[:uuid]
							@comments = BlogService.getBlogComments(@params[:uuid])
							render :template => "blog/view"
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
					if DataService.canWrite?(BlogService.getCommentsUUID(@params[:uuid]), @user_uuid)
						# Validate the fields
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postuuid = @params[:uuid]
							if (@user_loggedin == false && @params[:uname].length > 0 && @params[:content].length > 0) || (@user_loggedin == true && @params[:content].length > 0)
								#BlogService.editBlogPost(@params[:uuid], @params[:title], @params[:description], @params[:content], nil, nil)
								if @user_loggedin == false
									BlogService.createBlogComment(@postuuid, ANONYMOUS, @params[:uname], @params[:content])
								else
									BlogService.createBlogComment(@postuuid, @user_uuid, nil, @params[:content])
								end
								redirect_to "/#{@type}/#{@name}/blog/view/#{@postuuid}/"
							else
								if @params[:content].length == 0
									@error = "Please enter a comment."
								elsif @user_loggedin == false && @params[:uname].length == 0
									@error = "Please enter a username."
								end
								@postmetadata = BlogService.getPostMetadata(@params[:uuid])
								@comments = BlogService.getBlogComments(@params[:uuid])
								render :template => "blog/view"
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
					if DataService.canWrite?(BlogService.getCommentsUUID(@params[:uuid]), @user_uuid)
						# Validate the fields
						@post = BlogService.getBlogPost(@params[:uuid])
						if @post == nil
							render :template => "errors/invalid_post"
						else
							@postuuid = @params[:uuid]
							if (@user_loggedin == false && @params[:uname].length > 0 && @params[:content].length > 0) || (@user_loggedin == true && @params[:content].length > 0)
								#BlogService.editBlogPost(@params[:uuid], @params[:title], @params[:description], @params[:content], nil, nil)
								if @user_loggedin == false
									BlogService.createBlogComment(@postuuid, ANONYMOUS, @params[:uname], @params[:content])
								else
									BlogService.createBlogComment(@postuuid, @user_uuid, nil, @params[:content])
								end								
								redirect_to "/#{@type}/#{@name}/blog/view/#{@postuuid}/"
							else
								if @params[:content].length == 0
									@error = "Please enter a comment."
								elsif @user_loggedin == false && @params[:uname].length == 0
									@error = "Please enter a username."
								end
								@postmetadata = BlogService.getPostMetadata(@params[:uuid])
								@comments = BlogService.getBlogComments(@params[:uuid])
								render :template => "blog/view"
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
			raise "Unrecognized HTTP request method in blog/view"
		end
	end
	
	def settings
		if request.method == :get
			if @params[:groupname] != nil
				@uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				@type = "group"
				if @uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
						render :template => "blog/settings"
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
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
						render :template => "blog/settings"
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
					@name = @params[:groupname].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
						# Validate the fields
						if @params[:title].length > 0
							DataService.modifyDataGroupMetadata(BlogService.getBlogUUID(@uuid), :title, @params[:title])
							DataService.modifyDataGroupMetadata(BlogService.getBlogUUID(@uuid), :description, @params[:description])
							redirect_to "/#{@type}/#{@name}/blog"
						else
							if @params[:title].length == 0
								@error = "Please enter a title for your blog."
							end
							render :template => "blog/settings"
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
					@name = @params[:username].downcase
					@blogmetadata = BlogService.getBlogMetadata(BlogService.getBlogUUID(@uuid))
					if DataService.canWrite?(BlogService.getBlogUUID(@uuid), @user_uuid)
						# Validate the fields
						if @params[:title].length > 0 
							DataService.modifyDataGroupMetadata(BlogService.getBlogUUID(@uuid), :title, @params[:title])
							DataService.modifyDataGroupMetadata(BlogService.getBlogUUID(@uuid), :description, @params[:description])
							redirect_to "/#{@type}/#{@name}/blog"
						else
							if @params[:title].length == 0
								@error = "Please enter a title for your blog."
							end
							render :template => "blog/settings"
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
