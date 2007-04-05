class EnvironmentController < ApplicationController
	layout "default"
	
	def index
		if params[:groupname] != nil
			@uuid = UserService.lookupGroupName(params[:groupname].downcase)
			if @uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "group"
				@name = params[:groupname].downcase
				i_envs = Environment.find(:all, :conditions => ["owner = ?", @uuid])
				@envs = Array.new
				
				if i_envs != nil
					i_envs.each do |env|
						if env.owner == @user_uuid || env.creator == @user_uuid || UserService.checkPermissions(UserService.loadPermissions(env.read_permissions), @user_uuid)
							# User can read this environment
							@envs << env
						end
					end
				end
			end
		elsif params[:username] != nil
			@uuid = UserService.lookupUserName(params[:username].downcase)
			if @uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				@type = "user"
				@name = params[:username].downcase
				if @uuid == @user_uuid
					set_tabs_for_user @user_username, true
					set_current_tab "environments"
				else
					set_tabs_for_user @name, false
					set_current_tab "environments"
				end
				i_envs = Environment.find(:all, :conditions => ["owner = ?", @uuid])
				@envs = Array.new
				if i_envs != nil
					i_envs.each do |env|
						if env.owner == @user_uuid || env.creator == @user_uuid || UserService.checkPermissions(UserService.loadPermissions(env.read_permissions), @user_uuid)
							# User can read this environment
							@envs << env
						end
					end
				end			
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end	
	
	def view
		if params[:groupname] != nil
			uuid = UserService.lookupGroupName(params[:groupname].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				if params[:envname] != nil
					@type = "group"
					@name = params[:groupname].downcase
					@envname = params[:envname].downcase
					@env = Environment.find(:first, :conditions => ["short_name = ? AND owner = ?", @envname, uuid])
					if @env != nil
						if UserService.checkPermissions(YAML::load(@env.read_permissions), @user_uuid)
							set_variables_for_env
						else
							render :template => "errors/access_denied"
						end
					else
						render :template => "errors/invalid_environment"
					end
				else
					render :template => "errors/invalid_environment"
				end
			end
		elsif params[:username] != nil
			uuid = UserService.lookupUserName(params[:username].downcase)
			if uuid == nil
				render :template => "errors/invalid_user_or_group"
			else
				if params[:envname] != nil
					@type = "user"
					@name = params[:username].downcase
					if uuid == @user_uuid
						set_tabs_for_user @user_username, true
						set_current_tab "environments"
					else
						set_tabs_for_user @name, false
						set_current_tab "environments"
					end					
					@envname = params[:envname].downcase
					@env = Environment.find(:first, :conditions => ["short_name = ? AND owner = ?", @envname, uuid])
					if @env != nil
						if UserService.checkPermissions(YAML::load(@env.read_permissions), @user_uuid)
							set_variables_for_env
						else
							render :template => "errors/access_denied"
						end
					else
						render :template => "errors/invalid_environment"
					end
				else
					render :template => "errors/invalid_environment"
				end
			end
		else
			render :template => "errors/invalid_user_or_group"
		end
	end
	
	private
		# Sets the variables for the environment, such as what widgets are in what column.
		def set_variables_for_env
			case @env.layout_type.downcase
				when "3-column"
					@env_widgets = Array.new
					@env_widgets << WidgetInstance.find(:all, :conditions => ["parent = ? AND position = 1", @env.uuid], :order => "`order` ASC")
					@env_widgets << WidgetInstance.find(:all, :conditions => ["parent = ? AND position = 2", @env.uuid], :order => "`order` ASC")
					@env_widgets << WidgetInstance.find(:all, :conditions => ["parent = ? AND position = 3", @env.uuid], :order => "`order` ASC")
			end
		end
end
