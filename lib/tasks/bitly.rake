gem "bitly"
require "bitly"

BITLY_USERNAME = "restlessnapkin"
BITLY_API_KEY = "R_2e4385747542533270d3c57b25e3a848"

namespace :macrodeck do
    namespace :bitly do
	desc "Creates bitly links for events"
	task :events => :environment do
	    Bitly.use_api_version_3
	    bitly = Bitly.new(BITLY_USERNAME, BITLY_API_KEY)

	    events = Event.view("by_missing_bitly_hash", :reduce => false, :include_docs => true)
	    events.each do |event|
		longurl = "http://www.restlessnapkin.com/countries/#{event.path[0]}/regions/#{event.path[1]}/localities/#{event.path[2]}/events/#{event.path[-1]}"
		bitly_url = bitly.shorten(longurl)
		event.bitly_hash = bitly_url.user_hash
		event.save
		puts "#{longurl} -> http://rnapk.in/#{bitly_url.user_hash}"
	    end
	end

	desc "Creates bitly links for places"
	task :places => :environment do
	    Bitly.use_api_version_3
	    bitly = Bitly.new(BITLY_USERNAME, BITLY_API_KEY)

	    places = Place.view("by_missing_bitly_hash", :reduce => false, :include_docs => true)
	    places.each do |place|
		longurl = "http://www.restlessnapkin.com/countries/#{place.path[0]}/regions/#{place.path[1]}/localities/#{place.path[2]}/places/#{place.path[-1]}"
		bitly_url = bitly.shorten(longurl)
		place.bitly_hash = bitly_url.user_hash
		place.save
		puts "#{longurl} -> http://rnapk.in/#{bitly_url.user_hash}"
	    end
	end
    end
end