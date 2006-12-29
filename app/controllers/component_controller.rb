class ComponentController < ApplicationController
	layout "default"
	
	def index
		set_current_tab "directory"
		@d_component_pages, @d_components = paginate :components, :order => "descriptive_name ASC", :per_page => 50
	end
	
	def view
		if @params[:internal_name] != nil
			@component = Component.find(:first, :conditions => ["internal_name = ?", @params[:internal_name]])
			if @component != nil
				# just aggregating the metadata -- no processing needed
				set_current_tab "directory"
			else
				render :template => "errors/invalid_component"
			end
		else
			render :template => "errors/invalid_component"
		end	
	end

	def new
		@component = Component.new
		if @component != nil
			# They can only add components if they're members of the MacroDeck Certified Developers group.
			if UserService.doesGroupMemberExist?(GROUP_DEVELOPERS, @user_uuid)
				set_current_tab "directory"
				if request.method == :get
					@descriptive_name = ""
					@internal_name = ""
					@description = ""
					@version = ""
					@homepage = ""
					@status = "alpha"
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
					render :template => "component/new"
				elsif request.method == :post
					@uuid = UUIDService.generateUUID()
					@descriptive_name = @params[:descriptive_name]
					@internal_name = @params[:internal_name]
					@description = @params[:description]
					@version = @params[:version]
					@homepage = @params[:homepage]
					@status = @params[:status]
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
					
					# Check values
					if @descriptive_name.length > 0
						if @internal_name.length > 0
							if @internal_name.split(".").length > 2 # If there are at least something.something.something, we're okay.
								if @description.length > 0
									if @version.length > 0
										if @homepage.length > 0
											if @status.length > 0
												if @status == "alpha" || @status == "beta" || @status == "testing" || @status == "release"
													if @code.length > 0
														# Check to see if the destination internal name exists.
														tmp_cmp = Component.find(:first, :conditions => ["internal_name = ?", @internal_name])
														if tmp_cmp == nil
															# Save component!
															@component.uuid = @uuid
															@component.descriptive_name = @descriptive_name
															@component.internal_name = @internal_name
															@component.description = @description
															@component.version = @version
															@component.homepage = @homepage
															@component.status = @status
															@component.code = @code
															@component.read_permissions = @readperms.to_yaml
															@component.write_permissions = @writeperms.to_yaml
															@component.owner = @user_uuid
															@component.creator = @user_uuid
															@component.creation = Time.now.to_i
															@component.updated = Time.now.to_i
															@component.save!
															redirect_to "/component/#{@internal_name}/"
														else
															@error = "The internal name you picked is already in use."
															render :template => "component/new"
														end
													else
														@error = "Please enter some code."
														render :template => "component/new"
													end
												else
													@error = "Please choose a valid release status."
													render :template => "component/new"
												end
											else
												@error = "Please select a release status."
												render :template => "component/new"
											end
										else
											@error = "Please enter a homepage (if you don't have one, use http://www.macrodeck.com/directory/components/)."
											render :template => "component/new"
										end
									else
										@error = "Please enter a version number."
										render :template => "component/new"
									end
								else
									@error = "Please enter a description."
									render :template => "component/new"
								end
							else
								@error = "You specified an invalid internal name. Something like com.yourname.ComponentName is what we want here."
								render :template => "component/new"
							end
						else
							@error = "Please enter an internal name for your component."
							render :template => "component/new"
						end
					else
						@error = "Please enter a name for your component."
						render :template => "component/new"
					end
				end
			else
				render :template => "errors/access_denied"
			end
		end
	end
	
	def edit
		if @params[:internal_name] != nil
			@component = Component.find(:first, :conditions => ["internal_name = ?", @params[:internal_name]])
			if @component != nil
				if @component.owner == @user_uuid || @component.creator == @user_uuid || UserService.checkPermissions(UserService.loadPermissions(@component.write_permissions), @user_uuid)
					set_current_tab "directory"
					if request.method == :get
						@uuid = @component.uuid
						@descriptive_name = @component.descriptive_name
						@internal_name = @component.internal_name
						@description = @component.description
						@version = @component.version
						@homepage = @component.homepage
						@status = @component.status
						@code = @component.code
						@readperms = UserService.loadPermissions(@component.read_permissions)
						@writeperms = UserService.loadPermissions(@component.write_permissions)
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
						render :template => "component/edit"
					elsif request.method == :post
						@uuid = @params[:uuid]
						@descriptive_name = @params[:descriptive_name]
						@internal_name = @params[:internal_name]
						@description = @params[:description]
						@version = @params[:version]
						@homepage = @params[:homepage]
						@status = @params[:status]
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
						
						# Check values
						if @descriptive_name.length > 0
							if @internal_name.length > 0
								if @internal_name.split(".").length > 2 # If there are at least something.something.something, we're okay.
									if @description.length > 0
										if @version.length > 0
											if @homepage.length > 0
												if @status.length > 0
													if @status == "alpha" || @status == "beta" || @status == "testing" || @status == "release"
														if @code.length > 0
															can_save = false
															if @component.internal_name == @internal_name
																# We're not changing the internal name
																can_save = true
															else
																# we are changing the internal name
																# see if a component already exists with this internal name.
																tmp_cmp = Component.find(:first, :conditions => ["internal_name = ?", @internal_name])
																if tmp_cmp == nil
																	# the destination component doesn't exist
																	can_save = true
																else
																	can_save = false
																	@error = "The internal name you picked is already in use."
																	render :template => "component/edit"
																end
															end
															if can_save
																# Save component!
																@component.descriptive_name = @descriptive_name
																@component.internal_name = @internal_name
																@component.description = @description
																@component.version = @version
																@component.homepage = @homepage
																@component.status = @status
																@component.code = @code
																@component.read_permissions = @readperms.to_yaml
																@component.write_permissions = @writeperms.to_yaml
																@component.owner = @user_uuid
																@component.creator = @user_uuid
																@component.updated = Time.now.to_i
																@component.save!
																redirect_to "/component/#{@internal_name}/"
															end
														else
															@error = "Please enter some code."
															render :template => "component/edit"
														end
													else
														@error = "Please choose a valid release status."
														render :template => "component/edit"
													end
												else
													@error = "Please select a release status."
													render :template => "component/edit"
												end
											else
												@error = "Please enter a homepage (if you don't have one, use http://www.macrodeck.com/directory/components/)."
												render :template => "component/edit"
											end
										else
											@error = "Please enter a version number."
											render :template => "component/edit"
										end
									else
										@error = "Please enter a description."
										render :template => "component/edit"
									end
								else
									@error = "You specified an invalid internal name. Something like com.yourname.ComponentName is what we want here."
									render :template => "component/edit"
								end
							else
								@error = "Please enter an internal name for your component."
								render :template => "component/edit"
							end
						else
							@error = "Please enter a name for your component."
							render :template => "component/edit"
						end
					end
				else
					render :template => "errors/access_denied"
				end
			else
				render :template => "errors/invalid_component"
			end
		else
			render :template => "errors/invalid_component"
		end
	end	
	
	def code
		if @params[:internal_name] != nil
			@component = Component.find(:first, :conditions => ["internal_name = ?", @params[:internal_name]])
			if @widget != nil
				response.headers['Content-Type'] = 'text/javascript'
				render :partial => "code"
			else
				render :template => "errors/invalid_component"
			end
		else
			render :template => "errors/invalid_component"
		end
	end	
	
	def delete
		if @params[:internal_name] != nil
			@component = Component.find(:first, :conditions => ["internal_name = ?", @params[:internal_name]])
			if @component != nil
				if @component.owner == @user_uuid || @component.creator == @user_uuid || UserService.checkPermissions(UserService.loadPermissions(@component.write_permissions), @user_uuid)
					set_current_tab "directory"
					if request.method == :get
						render :template => 'component/delete'
					elsif request.method == :post
						@component.destroy
						redirect_to '/directory/components/'
					end
				else
					render :template => 'errors/access_denied'
				end
			else
				render :template => 'errors/invalid_component'
			end
		else
			render :template => 'errors/invalid_component'
		end	
	end
end
