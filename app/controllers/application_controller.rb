class ApplicationController < ActionController::Base

    # Stub. Returns true for now to activate the mobile layout.
    def mobile?
	true
    end
    
    def select_layout
	if mobile?
	    return "mobile"
	else
	    return "restlessnapkin"
	end
    end
    
    # Set no cache headers
    def do_not_cache
	headers["Expires"] = "Thu, 01 Jan 1970 01:00:00 GMT"
	headers["Last-Modified"] = Time.now.strftime("%a, %d %b %Y %H:%M:%S") + " GMT"
	headers["Cache-Control"] = "no-cache, must-revalidate"
	headers["Pragma"] = "no-cache"
    end
end
