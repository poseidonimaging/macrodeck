namespace :macrodeck do
    desc "Copies place information to events"
    task :event_place_info => :environment do
	events = Event.view("by_missing_place_info", :reduce => false, :include_docs => true)

	events.each do |e|
	    place = Place.get(e.path[-2])
	    unless place.nil?
		e['place'] ||= {}
		e['place']['title'] = place.title
		e['place']['description'] = place.description
		e['place']['address'] = place.address
		e['place']['geo'] = place.geo
		e['place']['fare'] = place.fare
		e['place']['features'] = place.features
		e.updated_by = "_system/event_place_info"

		if e.valid?
		    e.save
		else
		    puts "Event #{e.id} is not valid!"
		end
	    end
	end
    end
end