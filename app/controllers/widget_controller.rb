class WidgetController < ApplicationController
	layout "default"
	
	def index
		set_current_tab "directory"
		@d_widget_pages, @d_widgets = paginate :widgets, :order => "descriptive_name ASC", :per_page => 50
	end
	
	def view
		if @params[:uuid] != nil
			@widget = Widget.find(:first, :conditions => ["uuid = ?", @params[:uuid]])
			if @widget != nil
				# just aggregating the metadata -- no processing needed
				set_current_tab "directory"
				@dependencies = YAML::load(@widget.dependencies)
			else
				render :template => "errors/invalid_widget"
			end
		else
			render :template => "errors/invalid_widget"
		end
	end
	
	def edit
		if @params[:uuid] != nil
			@widget = Widget.find(:first, :conditions => ["uuid = ?", @params[:uuid]])
			if @widget != nil
				if UserService.checkPermissions(UserService.loadPermissions(@widget.write_permissions), @user_uuid)
					if request.method == :get
						@uuid = @widget.uuid
						@descriptive_name = @widget.descriptive_name
						@internal_name = @widget.internal_name
						@description = @widget.description
						@version = @widget.version
						@homepage = @widget.homepage
						@status = @widget.status
						@dependencies = @widget.dependencies
						@code = @widget.code
						render :template => "widget/edit"
					elsif request.method == :post
					end
				else
					render :template => "errors/access_denied"
				end
			else
				render :template => "errors/invalid_widget"
			end
		else
			render :template => "errors/invalid_widget"
		end
	end
	
	def code
		if @params[:uuid] != nil
			@widget = Widget.find(:first, :conditions => ["uuid = ?", @params[:uuid]])
			if @widget != nil
				response.headers['Content-Type'] = 'text/javascript'
				render :partial => "code"
			else
				render :template => "errors/invalid_widget"
			end
		else
			render :template => "errors/invalid_widget"
		end
	end
	
	# Returns a JavaScript fragment that will create a user info
	# object and run the widget's setUserInfo function so that
	# the widget knows the user's info.
	#
	#   @params[:objname] => the name of the object to run setUserInfo on
	#
	def set_user_info
		render :partial => "set_user_info"
	end
end
