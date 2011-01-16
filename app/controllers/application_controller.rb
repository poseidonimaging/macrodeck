class ApplicationController < ActionController::Base
    helper_method :"mobile?"
    helper_method :nilify
    helper_method :current_tab

    # Returns the current tab
    def current_tab
	if params[:tab].nil? || params[:tab].empty?
	    return nil
	else
	    return params[:tab].to_sym
	end
    end

    # Returns nil if blank.
    def nilify(str)
	if str.nil?
	    return nil
	elsif str.empty?
	    return nil
	else
	    return str
	end
    end

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

    # Converts degrees to radians.
    def degrees_to_radians(degrees)
	return degrees / (360 / (2 * Math::PI))
    end

    # Converts from radians to degrees
    def radians_to_degrees(radians)
	return radians * (360 / (2 * Math::PI))
    end

    # Determine the bounding box
    def get_bbox(lat, lng, radius)
	earth_radius = 3963.1676
	x1 = lat - radians_to_degrees(radius / earth_radius)
	x2 = lat + radians_to_degrees(radius / earth_radius)
	y1 = lng - radians_to_degrees((radius / earth_radius) / Math::cos(degrees_to_radians(lat)) )
	y2 = lng + radians_to_degrees((radius / earth_radius) / Math::cos(degrees_to_radians(lat)) )

	return [x1, y1, x2, y2]
    end

    # Handle search processing.
    def process_query(query)
	syns = [
	    [ "beer", "domestics", "pitchers", "buckets", "pints", "cans", "longnecks", "lone star", "high life", "bud", "miller", "bottles", "imports", "drafts" ],
	    [ "margaritas", "margs", "ritas", "marg", "rita" ],
	    [ "wells", "vodka", "whisky", "tequila", "you call it", "you call its", "liquor", "whiskey", "crown" ],
	    [ "appetizers", "apps", "appz", "tapas" ],
	    [ "shots", "bombs", "yeah babys" ]
	]

	result_query = []
	split_query = query.split(" ")
	split_query.each do |term|
	    # if term is AND or OR, skip
	    if term.downcase != "and" && term.downcase != "or"
		syns.each do |syn|
		    # The thought is only one synonym list would contain the term...
		    if syn.include? term.downcase
			# term is in the list of synonyms.
			term = '( "' + syn.join('" OR "') + '" )'
		    end
		end

		result_query << term
	    end
	end

	return result_query.join(" AND ")
    end
end
