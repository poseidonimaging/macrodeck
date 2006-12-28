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
				if request.method == :get
					@uuid = UUIDService.generateUUID()
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
				end
			else
				render :template => "errors/access_denied"
			end
		end
	end
end
