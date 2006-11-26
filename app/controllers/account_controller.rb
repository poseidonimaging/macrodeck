class AccountController < ApplicationController
	layout "default"
	
	def index
		# It's just a page.
	end
	def logout
		reset_session
		populate_user_variables
	end
	def create_group
		if @user_loggedin
			if @params[:step] == nil
				if @params[:groupname] == nil
					@groupname = nil
				else
					@groupname = @params[:groupname].downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
				end
				render :template => "account/create_group1"
			elsif @params[:step] == "1"
				@groupname = @params[:groupname].downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
				if @groupname.length > 0
					if UserService.doesGroupExist?(@groupname) == false
						@origgroupname = @params[:groupname]
						if @params[:grouplongname] != nil
							@grouplongname = @params[:grouplongname]
						else
							@grouplongname = @origgroupname
						end
						render :template => "account/create_group2"
					else
						@error = "The group short name you picked is already in use."
						render :template => "account/create_group1"
					end
				else
					@error = "The group short name you picked is invalid."
					render :template => "account/create_group1"
				end
			elsif @params[:step] == "2"
				@groupname = @params[:groupname]
				@grouplongname = @params[:grouplongname]
				@origgroupname = @params[:origgroupname]
				if @grouplongname.length > 0
					if @groupname.length > 0
						render :template => "account/create_group3"
					else
						# groupname len = 0
						@error = "The group short name you picked is invalid."
						render :template => "account/create_group2"
					end
				else
					@error = "You did not enter a group name."
					render :template => "account/create_group2"
				end
			elsif @params[:step] == "3"
				@groupname = @params[:groupname]
				@grouplongname = @params[:grouplongname]
				@origgroupname = @params[:origgroupname]
				@description = @params[:description]
				if @groupname.length > 0
					if @grouplongname.length > 0
						if UserService.doesGroupExist?(@groupname) == false
							uuid = UserService.createGroup(@groupname, @grouplongname)
							if uuid != nil
								UserService.setGroupProperty(uuid, :description, @description)
								UserService.addUserToGroup(uuid, @user_uuid, :administrator)
								# create blog for group
								blog_uuid = BlogService.createBlog("#{@grouplongname}'s Blog", @description, CREATOR_MACRODECK, uuid)
								BlogService.setBlogPermissions(blog_uuid, :read, [{ :id => "everyone", :action => :allow }])
								BlogService.setBlogPermissions(blog_uuid, :write, [{ :id => @user_uuid, :action => :allow }, { :id => "everyone", :action => :deny }])
								render :template => "account/create_group_finish"
							else
								@error = "Unable to create group. Please try again in a few seconds."
								render :template => "account/create_group3"
							end
						else
							@error = "The group short name you picked is already in use."
							render :template => "account/create_group3"
						end
					else
						@error = "The group long name you picked is invalid."
						render :template => "account/create_group3"
					end
				else
					@error = "The group short name you picked is invalid."
					render :template => "account/create_group3"
				end
			end
		else
			render :template => "errors/access_denied"
		end
	end
	
	def register
		# step 1 - username
		# step 2 - password, secret question, secret answer
		# step 3 - email, name, display name
		if @params[:step] == nil
			if @params[:username] == nil
				@username = nil
			else
				@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "")
			end
			render :template => "account/register1"
		elsif @params[:step] == "1"
			# validate username
			@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "") # should remove all non-word characters and remove spaces in case \W didn't catch them
			if @username.length > 0
				if UserService.doesUserExist?(@username) == false
					@origusername = @params[:username]
					render :template => "account/register2"
				else
					@error = "The username you picked is already in use."
					render :template => "account/register1"
				end
			else
				@error = "The username you picked is invalid."
				render :template => "account/register1"
			end
		elsif @params[:step] == "2"
			if request.method == :post
				# don't parse GET requests for sanity
				@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "") # in case someone tries to trick their way into the system with a bad username
				@origusername = @params[:origusername] # this is for their "display name" which will be displayed on step 3.
				@secretquestion = @params[:secretquestion]
				@secretanswer = @params[:secretanswer]
				# validate password
				if @params[:password1] != @params[:password2]
					@error = "Your passwords don't match."
					render :template => "account/register2"
				else
					# passwords match, are they long enough?
					@password = @params[:password1]
					if @password.length < 5
						@error = "Your password is too short (must be at least 5 characters long)."
						render :template => "account/register2"
					else
						# okay, they're long enough. what about the secret question?
						if @params[:secretquestion].length == 0
							@error = "You must enter a secret question."
							render :template => "account/register2"
						else
							# and what about the secret answer?
							if @params[:secretanswer].length == 0
								@error = "You must enter a secret answer."
								render :template => "account/register2"
							else
								# all is go! go to step 3.
								render :template => "account/register3"
							end						
						end	
					end				
				end
			else
				raise "Accessing account/register#2 via unsupported HTTP method!"
			end
		elsif @params[:step] == "3"
			if request.method == :post
				@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "") # wise guy, eh?
				@origusername = @params[:displayname]
				@secretquestion = @params[:secretquestion]
				@secretanswer = @params[:secretanswer]
				@password = @params[:password]
				@email = @params[:email]
				@displayname = @params[:displayname]
				@name = @params[:name]
				# Validate e-mail address
				if email_valid?(@email) == false
					@error = "Please enter a valid e-mail address."
					render :template => "account/register3"
				else
					# email is valid, check if display name is filled in.
					if @origusername.length == 0
						@error = "You have not entered a display name."
						render :template => "account/register3"
					else
						# that's valid, check the password.
						if @password.length == 0
							@error = "Somehow your password is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
							render :template => "account/register3"
						else
							# okay, the password isn't screwy. check the secret question
							if @secretquestion.length == 0
								@error = "Somehow your secret question is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
								render :template => "account/register3"
							else
								# secret question is good, check secret answer
								if @secretanswer.length == 0
									@error = "Somehow your secret answer is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
									render :template => "account/register3"
								else
									# secret answer is good, check username in case they're attempting to specify a null one.
									if @username.length == 0
										@error = "Somehow your username is blank. This is probably a filter or some Internet security software running on your computer. Please try registering again from the <a href=\"/account/register\">beginning</a>."
										render :template => "account/register3"
									else
										# it checks out, boss!
										uuid = UserService.createUser(@username, @password, @secretquestion, @secretanswer, @name, @displayname, @email)
										if uuid != nil
											blog_uuid = BlogService.createBlog("#{@username}'s Blog", nil, CREATOR_MACRODECK, uuid)
											BlogService.setBlogPermissions(blog_uuid, :read, [{ :id => "everyone", :action => :allow }])
											BlogService.setBlogPermissions(blog_uuid, :write, [{ :id => @user_uuid, :action => :allow }, { :id => "everyone", :action => :deny }])
											render :template => "account/registerdone"
										else
											@error = "There was an error creating your user account. Please try again."
											render :template => "account/register3"
										end
									end
								end
							end
						end
					end
				end
			else
				raise "Accessing account/register#3 via unsupported HTTP method!"
			end
		else
			raise "Unknown action in account/register!"
		end
	end
	def login
		if request.method == :post
			# The form was POSTed. We're going to do a login.
			@authcode = UserService.authenticate(@params[:username].downcase.gsub(/\W/, "").gsub(" ", ""), @params[:password], request.remote_ip)
			@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "")
			if @authcode == nil
				# Error authenticating
				@error = "Invalid username or password."
				render :template => "account/login"
			else
				verified_email = UserService.getUserProperty(@authcode[:uuid], @authcode[:authcode], :verified_email)
				if verified_email == true
					reset_session
					session[:authcode] = @authcode[:authcode]
					session[:uuid] = @authcode[:uuid]
					redirect_to "/user/#{@username}/home/"
				else
					@error = "Your account's e-mail address has not yet been verified. Please check your e-mail for instructions on how to verify your e-mail address. You may need to check your spam filter."
					render :template => "account/login"
				end
			end
		elsif request.method == :get
			# TODO: if logged in already, let the user know that they're already logged in
			if session != nil
				if session[:authcode] != nil && session[:uuid] != nil
					# assume logged in already.
					render :template => "errors/already_logged_in"
				end
			end
		else
			raise "Unsupported HTTP Method!"
		end
	end
	def home
		if @params[:username] != nil
			uuid = UserService.lookupUserName(@params[:username].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				if session != nil
					if session[:authcode] != nil && session[:uuid] != nil
						verify_authcode = UserService.verifyAuthCode(@session[:uuid], @session[:authcode])
						@username = @params[:username].downcase
						if verify_authcode == true
							# there's no real data put on the homepage yet.
							set_tabs_for_user(@username, true)
							set_current_tab "home"
						else
							render :template => "errors/access_denied"
						end
					else
						render :template => "errors/access_denied"
					end
				else
					render :template => "errors/access_denied"
				end
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end
	def profile
		if request.method == :get
			if @params[:groupname] != nil
				uuid = UserService.lookupGroupName(@params[:groupname].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					@type = "group"
					@name = @params[:groupname].downcase
					
				end
			elsif @params[:username] != nil
				uuid = UserService.lookupUserName(@params[:username].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
				end
			else
				render :template => "errors/invalid_user_or_group"
			end
		elsif request.method == :post
			# edit profile.
		end
	end
	def settings
		# This could probably support groups quite easily...
		if request.method == :post
			if @params[:username] != nil
				uuid = UserService.lookupUserName(@params[:username].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					if session != nil
						if session[:authcode] != nil && session[:uuid] != nil
							verify_authcode = UserService.verifyAuthCode(@session[:uuid], @session[:authcode])
							if verify_authcode == true
								@username = @params[:username].downcase.gsub(/\W/, "").gsub(" ", "") # wise guy, eh?
								@displayname = @params[:displayname]
								@secretquestion = @params[:secretquestion]
								@secretanswer = @params[:secretanswer]
								@password1 = @params[:password1]
								@password2 = @params[:password2]
								@email = @params[:email]
								@name = @params[:name]
								set_tabs_for_user(@username, true)
								set_current_tab "settings"
								
								# Validate e-mail address
								if email_valid?(@email) == false
									@error = "Please enter a valid e-mail address."
									render :template => "account/settings"
								else
									# email is valid, check if display name is filled in.
									if @displayname.length == 0
										@error = "You have not entered a display name."
										render :template => "account/settings"
									else
										# that's valid, check the password.
										if @password1.length != 0 && @password1 != @password2
											@error = "Your passwords don't match."
											render :template => "account/settings"
										else
											if @password1.length != 0 && @password1.length < 5
												@error = "Your new password is too short."
												render :template => "account/settings"
											else
												# okay, the password isn't screwy. check the secret question
												if @secretquestion.length == 0
													@error = "Your secret question cannot be blank."
													render :template => "account/settings"
												else
													# secret question is good, check secret answer
													if @secretanswer.length == 0
														@error = "Your secret answer cannot be blank."
														render :template => "account/settings"
													else
														# everything checks out correctly.
														if @password1 == @password2 && @password1.length > 0
															UserService.setUserProperty(session[:uuid], session[:authcode], :password, @password1)
															# re-authenticate to update the authcode.
															@authcode = UserService.authenticate(@username, @password1, request.remote_ip)
															reset_session
															session[:authcode] = @authcode[:authcode]
															session[:uuid] = @authcode[:uuid]
														end
														UserService.setUserProperty(session[:uuid], session[:authcode], :secretquestion, @secretquestion)
														UserService.setUserProperty(session[:uuid], session[:authcode], :secretanswer, @secretanswer)
														UserService.setUserProperty(session[:uuid], session[:authcode], :name, @name)
														UserService.setUserProperty(session[:uuid], session[:authcode], :displayname, @displayname)
														UserService.setUserProperty(session[:uuid], session[:authcode], :email, @email)
														@info = "Successfully applied changes"
														populate_user_variables #reload the user info for the top thingy
														render :template => "account/settings"
													end
												end
											end
										end
									end				
								end
							else
								render :template => "errors/access_denied"
							end
						else
							render :template => "errors/access_denied"
						end
					else
						render :template => "errors/access_denied"
					end
				end
			else
				render :template => "errors/invalid_user_or_group"
			end			
		elsif request.method == :get
			if @params[:username] != nil
				uuid = UserService.lookupUserName(@params[:username].downcase)
				if uuid == nil
					render :template => "errors/invalid_user_or_group"
				else
					if session != nil
						if session[:authcode] != nil && session[:uuid] != nil
							verify_authcode = UserService.verifyAuthCode(@session[:uuid], @session[:authcode])
							if verify_authcode == true
								@displayname = UserService.getUserProperty(@session[:uuid], @session[:authcode], :displayname)
								@name = UserService.getUserProperty(@session[:uuid], @session[:authcode], :name)
								@secretquestion = UserService.getUserProperty(@session[:uuid], @session[:authcode], :secretquestion)
								@secretanswer = UserService.getUserProperty(@session[:uuid], @session[:authcode], :secretanswer)
								@email = UserService.getUserProperty(@session[:uuid], @session[:authcode], :email)
								@username = @params[:username].downcase
								set_tabs_for_user(@username, true)
								set_current_tab "settings"								
							else
								render :template => "errors/access_denied"
							end
						else
							render :template => "errors/access_denied"
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
