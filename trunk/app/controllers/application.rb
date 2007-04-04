# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
	before_filter :check_authcode, :update_session, :populate_user_variables, :reset_tabs, :reset_widget_vars

	# If a session is present, renew it. 
	def update_session
		if @session
			::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_expires => 3.days.from_now )
		end
		return true
	end
	
	# Checks a client's authcode against our records
	def check_authcode
		if @session
			if @session[:authcode] != nil && @session[:uuid] != nil
				validcode = UserService.verifyAuthCode(@session[:uuid], @session[:authcode])
				if validcode == false
					# you dirty dirty man you!
					reset_session
				end
			else
				# The session has been partially destroyed
				# and we don't know why.
				reset_session
			end
		end
		return true
	end
	
	# Resets the widget variables
	def reset_widget_vars
		@widgets = Array.new
		@components = Array.new
	end
	
	# Sets the tabs to default; changed whenever a page sets another kind of tabs
	def reset_tabs
		@tabs = DEFAULT_TABS
		@current_tab = nil
	end
	
	def set_tabs(tabs)
		@tabs = tabs
	end
	
	# Sets the current tabs to the user tabs
	# Specify the name of the user, and if they're
	# the person viewing the tabs.
	def set_tabs_for_user(name, isUser)
		if isUser
			tabs = 	[{ :url => "/user/#{name}/home/",			:text => "My Home",			:id => "home" },
					 { :url => "/user/#{name}/blog/",			:text => "My Blog",			:id => "blog" },
					 { :url => "/user/#{name}/environments/", 	:text => "My Environments", :id => "environments" },
					 { :url => "/user/#{name}/shared/",			:text => "My Shared Items",	:id => "shareditems" },
					 { :url => "/user/#{name}/settings/",		:text => "My Settings",		:id => "settings" }]
			@tabs = tabs
		else
			tabs = 	[{ :url => "/user/#{name}/blog/",			:text => "#{name}'s Blog",			:id => "blog" },
					 { :url => "/user/#{name}/profile/",	 	:text => "#{name}'s Profile",		:id => "profile" },
					 { :url => "/user/#{name}/shared/",			:text => "#{name}'s Shared Items",	:id => "shareditems" }]
			@tabs = tabs
		end
	end
	
	def set_current_tab(tabID)
		@current_tab = tabID
	end
	
	# Populates some variables related to the current logged on user, if any.
	def populate_user_variables
		@user_loggedin = nil
		@user_username = nil
		@user_name = nil
		@user_displayname = nil
		@user_uuid = nil
		@user_authcode = nil
		
		if @session
			if @session[:authcode] != nil && @session[:uuid] != nil
				if UserService.getUserProperty(@session[:uuid], @session[:authcode], :username) != nil
					@user_loggedin = true
					@user_username = UserService.getUserProperty(@session[:uuid], @session[:authcode], :username)
					@user_name = UserService.getUserProperty(@session[:uuid], @session[:authcode], :name)
					@user_displayname = UserService.getUserProperty(@session[:uuid], @session[:authcode], :displayname)
					@user_authcode = @session[:authcode]
					if @user_name != nil
						@user_firstname = @user_name.split(" ")[0]
					else
						@user_firstname = nil
					end
					@user_uuid = @session[:uuid]
				else
					@user_uuid = "anonymous"
					@user_loggedin = false
				end
			else
				@user_uuid = "anonymous"
				@user_loggedin = false
			end
		else
			@user_uuid = "anonymous"
			@user_loggedin = false
		end
		return true
	end
	
	# Is the e-mail address specified a valid address?
	def email_valid?(email)
		if email =~ EMAIL_VALIDATION
			return true
		else
			return false
		end
	end
	
	# Set no cache headers
	def do_not_cache
		@headers["Expires"] = "Mon, 20 Dec 1998 01:00:00 GMT"
		@headers["Last-Modified"] = Time.now.strftime("%a, %d %b %Y %H:%M:%S") + " GMT"
		@headers["Cache-Control"] = "no-cache, must-revalidate"
		@headers["Pragma"] = "no-cache"
	end
end