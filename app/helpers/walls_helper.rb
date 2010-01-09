# This helper has wall functions in it.
module WallsHelper
	def get_wall_path
		# FIXME: params[:id] needs to map to whatever it's supposed to below.
		country		= params[:country_id]
		state		= params[:state_id]
		city		= params[:city_id]
		place		= params[:place_id]
		calendar	= params[:calendar_id]
		event		= params[:event_id]

		# These three will always not be nil.
		if !country.nil? && !state.nil? && !city.nil?
			# Place walls.
			if !place.nil? && calendar.nil? && event.nil?
				return country_state_city_place_wall_path(country, state, city, place)
			# Place calendar walls.
			elsif !place.nil? && !calendar.nil? && event.nil?
				return country_state_city_place_calendar_wall_path(country, state, city, place, calendar)
			# Place event walls.
			elsif !place.nil? && !calendar.nil? && !event.nil?
				return country_state_city_place_calendar_event_wall_path(country, state, city, place, calendar, event)
			# City calendar walls.
			elsif place.nil? && !calendar.nil? && event.nil?
				return country_state_city_calendar_wall_path(country, state, city, calendar)
			# City event walls.
			elsif place.nil? && !calendar.nil? && !event.nil?
				return country_state_city_calendar_event_wall_path(country, state, city, calendar, event)
			# City walls.
			elsif place.nil? && calendar.nil? && event.nil?
				return country_state_city_wall_path(country, state, city)
			else
				return nil
			end
		else
			return nil
		end
	end
end
