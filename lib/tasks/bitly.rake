gem "bitly"
require "bitly"

BITLY_USERNAME = "restlessnapkin"
BITLY_API_KEY = "R_2e4385747542533270d3c57b25e3a848"

namespace :macrodeck do
    namespace :bitly do
	desc "Creates bitly links for events"
	task :events => :environment do
	    events = Event.all
	    events.each do |event|
		longurl = "http://www.restlessnapkin.com/countries/#{event.path[0]}/regions/#{event.path[1]}/localities/#{event.path[2]}/events/#{event.path[-1]}"
		puts longurl
	    end
	end
    end
end