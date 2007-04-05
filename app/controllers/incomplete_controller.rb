class IncompleteController < ApplicationController
	layout "default"
	
	def index
		# no content yet.
	end
	
	def directory
		set_current_tab "directory"
	end
	
	def environments
		if params[:groupname] != nil
			uuid = UserService.lookupGroupName(params[:groupname].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "group"
				@name = params[:groupname].downcase
				# no tabs to set yet!
			end
		elsif params[:username] != nil
			uuid = UserService.lookupUserName(params[:username].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "user"
				@name = params[:username].downcase
				if @user_username != nil && @name == @user_username.downcase
					set_tabs_for_user(@name, true)
					set_current_tab "environments"
				else
					set_tabs_for_user(@name, false)
					set_current_tab "environments"
				end
			end
		else
			render :template => "errors/invalid_user_or_group"
		end		
	end
	
	def shareditems
		if params[:groupname] != nil
			uuid = UserService.lookupGroupName(params[:groupname].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "group"
				@name = params[:groupname].downcase
				# no tabs to set yet!
			end
		elsif params[:username] != nil
			uuid = UserService.lookupUserName(params[:username].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "user"
				@name = params[:username].downcase
				if @user_username != nil && @name == @user_username.downcase
					set_tabs_for_user(@name, true)
					set_current_tab "shareditems"
				else
					set_tabs_for_user(@name, false)
					set_current_tab "shareditems"
				end
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end
	
	def profile
		if params[:groupname] != nil
			uuid = UserService.lookupGroupName(params[:groupname].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "group"
				@name = params[:groupname].downcase
				# no tabs to set yet!
			end
		elsif params[:username] != nil
			uuid = UserService.lookupUserName(params[:username].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "user"
				@name = params[:username].downcase
				if @user_username != nil && @name == @user_username.downcase
					set_tabs_for_user(@name, true)
					set_current_tab "profile"
				else
					set_tabs_for_user(@name, false)
					set_current_tab "profile"
				end
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end	
end
