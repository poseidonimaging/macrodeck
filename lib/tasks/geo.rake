require "geokit"

GEOAPI_KEY = "vIAOECQLnv"
YAHOO_KEY = "FO9Li6nV34Ge6YvB_v93jlm06tBKjZIQezN8qp_1YneKZzu1Ts2XiJNTK5Z7EVAsU6iO"

namespace :macrodeck do
    desc "Clears geo information"
    task :clear_geocode => :environment do
	places = Place.all
	places.each do |p|
	    p.update_attributes "geo" => nil
	end
    end

    desc "Goes through places and gets their lat/lngs"
    task :geocode => :environment do
	Geokit::Geocoders::yahoo = YAHOO_KEY
	places = Place.view("by_missing_geo", :reduce => false, :include_docs => true)
	
	places.each do |p|
	    locality_path = p.path[0..2]
	    region_path = p.path[0..1]
	    locality = Locality.view("by_path", :startkey => locality_path, :limit => 1, :reduce => false, :include_docs => true)[0]
	    region = Region.view("by_path", :startkey => region_path, :limit => 1, :reduce => false, :include_docs => true)[0]
	    address = "#{p.address}, #{locality.title}, #{region.title}"
	    georesult = Geokit::Geocoders::YahooGeocoder.geocode address
	    if georesult.lat && georesult.lng
		puts "--- Geocoded #{address} to #{georesult.lat}, #{georesult.lng}"
		p.geo = [georesult.lat, georesult.lng]
		p.updated_by = "_system/geocode"
		p.save
	    else
		puts "!!! Could not geocode #{address}."
	    end
	end
    end
end