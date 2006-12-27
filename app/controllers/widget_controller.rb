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
				@required_components = YAML::load(@widget.required_components)
			else
				render :template => "errors/invalid_widget"
			end
		else
			render :template => "errors/invalid_widget"
		end
	end
	
	def delete
		if @params[:uuid] != nil
			@widget = Widget.find(:first, :conditions => ["uuid = ?", @params[:uuid]])
			if @widget != nil
				if UserService.checkPermissions(UserService.loadPermissions(@widget.write_permissions), @user_uuid)
					if request.method == :get
						render :template => 'widget/delete'
					elsif request.method == :post
						@widget.destroy
						redirect_to '/directory/widgets/'
					end
				else
					render :template => 'errors/access_denied'
				end
			else
				render :template => 'errors/invalid_widget'
			end
		else
			render :template => 'errors/invalid_widget'
		end
	end

	def new
		if @params[:uuid] != nil
			@widget = Widget.new
			if @widget != nil
				# They can only add widgets if they're members of the MacroDeck Certified Developers group.
				if UserService.doesGroupMemberExist?(GROUP_DEVELOPERS, @user_uuid)
					if request.method == :get
						@uuid = UUIDService.generateUUID()
						@descriptive_name = ""
						@internal_name = ""
						@description = ""
						@version = ""
						@homepage = ""
						@status = "alpha"
						@required_components = Array.new
						@code = ""
						@readperms = DEFAULT_READ_PERMISSIONS
						@writeperms = DEFAULT_WRITE_PERMISSIONS
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
						render :template => "widget/new"
					elsif request.method == :post
						@uuid = @params[:uuid]
						@descriptive_name = @params[:descriptive_name]
						@internal_name = @params[:internal_name]
						@description = @params[:description]
						@version = @params[:version]
						@homepage = @params[:homepage]
						@status = @params[:status]					
						rcomp_array = Array.new
						rcomps = @params[:components].sort
						rcomps.each do |rcomp|
							rcomp[1].each_pair do |key, value|
								if value == "enabled"
									rcomp_array << key
								end
							end
						end
						@required_components = rcomp_array
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
						if @descriptive_name.length > 0
							if @internal_name.length > 0
								if @description.length > 0
									if @version.length > 0
										if @homepage.length > 0
											if @status.length > 0
												if @status == "alpha" || @status == "beta" || @status == "testing" || @status == "release"
													if @code.length > 0
														if @uuid.length > 0
															# Save widget
															@widget.uuid = @uuid
															@widget.descriptive_name = @descriptive_name
															@widget.internal_name = @internal_name
															@widget.description = @description
															@widget.version = @version
															@widget.homepage = @homepage
															@widget.status = @status
															@widget.code = @code
															@widget.read_permissions = @readperms.to_yaml
															@widget.write_permissions = @writeperms.to_yaml
															@widget.required_components = @required_components.to_yaml
															@widget.save!
															redirect_to "/widget/#{@uuid}/"
														else
															@error = "Invalid UUID. Please check your firewall's settings."
															render :template => "widget/new"
														end
													else
														@error = "Please enter some code."
														render :template => "widget/new"
													end
												else
													@error = "You have somehow picked an invalid release status."
													render :template => "widget/new"
												end
											else
												@error = "You have somehow picked an invalid release status."
												render :template => "widget/new"
											end
										else
											@error = "You must enter a homepage. If you don't have one, use your widget's info page."
											render :template => "widget/new"
										end
									else
										@error = "Please enter a version number."
										render :template => "widget/new"
									end
								else
									@error = "Please enter a description."
									render :template => "widget/new"
								end
							else
								@error = "Please enter your widget's internal name (the JavaScript class object name)."
								render :template => "widget/new"
							end
						else
							@error = "Please enter a descriptive name for people browsing."
							render :template => "widget/new"
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
						@required_components = YAML::load(@widget.required_components)
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
						rcomp_array = Array.new
						rcomps = @params[:components].sort
						rcomps.each do |rcomp|
							rcomp[1].each_pair do |key, value|
								if value == "enabled"
									rcomp_array << key
								end
							end
						end
						@required_components = rcomp_array
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
						if @descriptive_name.length > 0
							if @internal_name.length > 0
								if @description.length > 0
									if @version.length > 0
										if @homepage.length > 0
											if @status.length > 0
												if @status == "alpha" || @status == "beta" || @status == "testing" || @status == "release"
													if @code.length > 0
														# Save widget
														@widget.descriptive_name = @descriptive_name
														@widget.internal_name = @internal_name
														@widget.description = @description
														@widget.version = @version
														@widget.homepage = @homepage
														@widget.status = @status
														@widget.code = @code
														@widget.read_permissions = @readperms.to_yaml
														@widget.write_permissions = @writeperms.to_yaml
														@widget.required_components = @required_components.to_yaml
														@widget.save!
														redirect_to "/widget/#{@uuid}/"
													else
														@error = "Please enter some code."
														render :template => "widget/edit"
													end
												else
													@error = "You have somehow picked an invalid release status."
													render :template => "widget/edit"
												end
											else
												@error = "You have somehow picked an invalid release status."
												render :template => "widget/edit"
											end
										else
											@error = "You must enter a homepage. If you don't have one, use your widget's info page."
											render :template => "widget/edit"
										end
									else
										@error = "Please enter a version number."
										render :template => "widget/edit"
									end
								else
									@error = "Please enter a description."
									render :template => "widget/edit"
								end
							else
								@error = "Please enter your widget's internal name (the JavaScript class object name)."
								render :template => "widget/edit"
							end
						else
							@error = "Please enter a descriptive name for people browsing."
							render :template => "widget/edit"
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
