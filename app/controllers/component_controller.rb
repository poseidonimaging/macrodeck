class ComponentController < ApplicationController
	layout "default"
	
	def index
		set_current_tab "directory"
		@d_component_pages, @d_components = paginate :components, :order => "descriptive_name ASC", :per_page => 50
	end	
end
