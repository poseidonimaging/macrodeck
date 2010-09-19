class ApplicationController < ActionController::Base
    helper_method :"mobile?"

    # Stub. Returns true for now to activate the mobile layout.
    def mobile?
	if @desktop_override.nil? || @desktop_override == false
	    return true
	else
	    return false
	end
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

    def render_404(exception = nil)
	if exception
	    logger.info "Rendering 404 with exception: #{exception.message}"
	end

	respond_to do |format|
	    format.html { render :file => "#{Rails.root}/public/404.html", :status => :not_found }
	    format.xml  { head :not_found }
	    format.any  { head :not_found }
	end
    end
end
