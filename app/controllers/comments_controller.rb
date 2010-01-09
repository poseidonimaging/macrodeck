# This controller handles Comment objects.
class CommentsController < ApplicationController
	layout 'default'
	before_filter :find_country
	before_filter :find_state
	before_filter :find_city
	before_filter :find_place	# may not be used; only if comments exist on an event/calendar.
	before_filter :find_calendar	# may not be used; only if comments exist on an event/calendar.
	before_filter :find_event	# may not be used; only if comments exist on an event/calendar.
	before_filter :find_wall
	before_filter :find_comment

	# List all comments
	def index
		@comments = @wall.comments
		
		respond_to do |format|
			format.html # index.html.erb 
		end
	end

	# This shows a specific comment.
	# FIXME: Implement this.
	def show
		raise NotImplementedError, "FIXME: Implement showing comments."
	end
	
	# Shows the interface for editing a comment.
	def edit
		raise NotImplementedError, "FIXME: Implement editing comments."
		#respond_to do |format|
		#	format.html # edit.html.erb
		#end
	end
	
	# Handles updating a comment
	# FIXME: Implement this.
	def update
		raise NotImplementedError, "FIXME: Implement editing comments."
		
=begin
		if @event.update_attributes(params[:event])
			if @place.nil?
				respond_to do |format|
					format.html { redirect_to(country_state_city_event_path(params[:country_id], params[:state_id], params[:city_id], params[:id])) }
					format.xml  { head :ok }
				end
			else
				respond_to do |format|
					format.html { redirect_to(country_state_city_place_event_path(params[:country_id], params[:state_id], params[:city_id], params[:place_id], params[:id])) }
					format.xml  { head :ok }
				end
			end
		else
			respond_to do |format|
				format.html { render :action => "edit" }
				format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
			end
		end
=end
	end
	
	# Handles creating a comment.
	def create
		@comment = @wall.comments.build(params[:comment])
		
		if @comment.save
			respond_to do |format|
				format.html { redirect_to(get_wall_path) }
				format.xml  { head :ok }
			end
		else
			respond_to do |format|
				format.html { render :action => "edit" }
				format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
			end
		end
	end

	private
		# Finds the country associated with the request.
		def find_country
			@country = Category.find_by_parent_uuid_and_url_part(Category.find(:first, :conditions => ["parent_uuid IS NULL AND url_part = ?", "places"]).uuid, params[:country_id].downcase) if params[:country_id]
		end

		# Finds the state associated with the request.
		def find_state
			@state = Category.find_by_parent_uuid_and_url_part(@country.uuid, params[:state_id].downcase) if params[:country_id] && params[:state_id]
		end

		# Finds the city associated with the request
		def find_city
			if params[:country_id] && params[:state_id] && params[:city_id]
				# Walk the tree 
				city_category = Category.find_by_parent_uuid_and_url_part(@state.uuid, params[:city_id].downcase)
				@city = City.find(:first, :conditions => { :category_id => city_category.id })
			end
		end

		# Finds the place associated with the request (if any)
		def find_place
			if params[:country_id] && params[:state_id] && params[:city_id] && params[:place_id] && params[:place_id].length > 0
				@place = Place.find(:first, :conditions => ["url_part = ? OR uuid = ?", params[:place_id], params[:place_id]])
			end
		end
		
		# Finds the calendar associated with the request
		def find_calendar
			if @place.nil?
				# We need to get the city's calendar.
				@calendar = @city.calendar
			else
				@calendar = @place.calendar
			end
		end

		# Finds the event associated with the request (if any)
		def find_event
			if params[:event_id] && params[:event_id].length > 0
				@event = Event.find(:first, :conditions => ["url_part = ? OR uuid = ?", params[:event_id], params[:event_id]])
			end
		end
		
		# Finds the wall associated with the request
		def find_wall
			[@calendar, @event, @city, @place].each do |parent|
				@wall = parent.wall if !parent.nil? && parent.respond_to?(:wall)
			end
		end
		
		# Finds the comment associated with the request
		def find_comment
			if params[:id] && params[:id].length > 0
				@comment = Comment.find(:first, :conditions => ["url_part = ? OR uuid = ?", params[:id], params[:id]])
			end
		end
end

