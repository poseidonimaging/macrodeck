class HomeController < ApplicationController
	layout 'restlessnapkin'

	def index
		# static content
	end
	
	# SXSW 08 Austin Events page
	def sxsw
		austincat = 54
		upcoming_events = Calendar.upcoming_events_in_category(austincat)
		
		if upcoming_events
			@events = upcoming_events.paginate(:page => params[:page], :per_page => 20)
		else
			@events = nil
		end
	end
end
