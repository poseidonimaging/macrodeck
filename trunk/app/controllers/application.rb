# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
	before_filter :check_authcode, :update_session, :populate_user_variables, :reset_tabs

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
	
	def reset_tabs
		# Sets the tabs to default; changed whenever a page sets another kind of tabs
		@tabs = DEFAULT_TABS
	end
	
	# Populates some variables related to the current logged on user, if any.
	def populate_user_variables
		if @session
			if @session[:authcode] != nil && @session[:uuid] != nil
				if UserService.getUserProperty(@session[:uuid], @session[:authcode], :username) != nil
					@user_loggedin = true
					@user_username = UserService.getUserProperty(@session[:uuid], @session[:authcode], :username)
					@user_name = UserService.getUserProperty(@session[:uuid], @session[:authcode], :name)
					@user_displayname = UserService.getUserProperty(@session[:uuid], @session[:authcode], :displayname)
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
end