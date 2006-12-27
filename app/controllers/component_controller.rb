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
end
