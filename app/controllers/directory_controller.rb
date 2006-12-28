class DirectoryController < ApplicationController
	layout "default"
	
	def index
		set_current_tab "directory"
	end
end
