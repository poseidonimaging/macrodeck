class WidgetController < ApplicationController
	layout "default"
	
	def index
		set_current_tab "directory"
		@widget_pages, @widgets = paginate :widgets, :order => "descriptive_name ASC", :per_page => 50
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
end
