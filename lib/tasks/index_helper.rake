namespace :macrodeck do
    desc "Copies place information to events"
    task :event_place_info => :environment do
	events = Event.view("by_missing_place_info", :reduce => false, :include_docs => true)

	events.each do |e|
	    place = Place.get(e.path[-2])
	    unless place.nil?
		e['_place'] ||= {}
		e['_place']['title'] = place.title
		e['_place']['description'] = place.description
		e['_place']['address'] = place.address
		e['_place']['geo'] = place.geo
		e['_place']['fare'] = place.fare
		e['_place']['features'] = place.features

		if e.valid?
		    e.save
		else
		    puts "Event #{e.id} is not valid!"
		end
	    end
	end
    end
end