class HomeController < ApplicationController
	layout 'default'

	def index
		# static content
	end
	
	# SXSW 08 Austin Events page
	def sxsw
	  austincat = Category.find_by_title("Austin")
	  if austincat
	    upcoming_events = Calendar.upcoming_events_in_category(austincat.id)
	    if upcoming_events
	      # RENDER!
	      @events = upcoming_events.paginate(:page => params[:page], :per_page => 20)
	    else
	      @events = nil
	    end
	  else
	    raise "Austin category does not exist."
	  end
	end
end
