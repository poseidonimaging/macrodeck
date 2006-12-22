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
						@dependencies = YAML::load(@widget.dependencies)
						@code = @widget.code
						@readperms = UserService.loadPermissions(@widget.read_permissions)
						@writeperms = UserService.loadPermissions(@widget.write_permissions)
						if @status == "alpha"
							@status_tags = '<option selected="selected" value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option value="release">Release</option>'
						elsif @status == "beta"
							@status_tags = '<option value="alpha">Alpha</option>
											<option selected="selected" value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option value="release">Release</option>'
						elsif @status == "testing"
							@status_tags = '<option value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option selected="selected" value="testing">Testing</option>
											<option value="release">Release</option>'
						elsif @status == "release"
							@status_tags = '<option value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option selected="selected" value="release">Release</option>'
						else
							@status_tags = '<option value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option value="release">Release</option>'
						end
						render :template => "widget/edit"
					elsif request.method == :post
						@uuid = @params[:uuid]
						@descriptive_name = @params[:descriptive_name]
						@internal_name = @params[:internal_name]
						@description = @params[:description]
						@version = @params[:version]
						@homepage = @params[:homepage]
						@status = @params[:status]
						@dependencies = @params[:dependencies]
						@code = @params[:code]
						@readperms = PermissionController.parse_permissions(@params[:read])
						@writeperms = PermissionController.parse_permissions(@params[:write])
						if @status == "alpha"
							@status_tags = '<option selected="selected" value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option value="release">Release</option>'
						elsif @status == "beta"
							@status_tags = '<option value="alpha">Alpha</option>
											<option selected="selected" value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option value="release">Release</option>'
						elsif @status == "testing"
							@status_tags = '<option value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option selected="selected" value="testing">Testing</option>
											<option value="release">Release</option>'
						elsif @status == "release"
							@status_tags = '<option value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option selected="selected" value="release">Release</option>'
						else
							@status_tags = '<option value="alpha">Alpha</option>
											<option value="beta">Beta</option>
											<option value="testing">Testing</option>
											<option value="release">Release</option>'
						end						
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
