# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
	before_filter :update_session

	# If a session is present, renew it. 
	def update_session
		if @session
			::ActionController::CgiRequest::DEFAULT_SESSION_OPTIONS.update(:session_expires => 3.days.from_now )
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