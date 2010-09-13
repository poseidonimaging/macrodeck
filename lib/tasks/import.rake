require "time"
require "fastercsv"

def read_file(file_name)
    line_number = 0
    root = ""
    done = false
    fields = []
    lines = []

    FasterCSV.foreach(file_name, :col_sep => "\t") do |line|
	line_number = line_number + 1
	if line_number == 1
	    root = line[0]
	    root = eval(root.to_s)
	elsif line_number == 2
	    fields = line.dup
	    fields.each_index do |field_id|
		fields[field_id] = fields[field_id].split(" ")[0].split("[")[0]
	    end
	elsif line_number > 2 && !done
	    line_arr = line.dup
	    line_hsh = {}
	    if line_arr == [] || line_arr == ["\n"]
		done = true
	    else
		line_arr.each_index do |item_id|
		    line_hsh[fields[item_id]] = line_arr[item_id]
		    line_hsh[fields[item_id]] = nil if line_hsh[fields[item_id]].nil? || line_hsh[fields[item_id]].empty?
		end
		lines << line_hsh
	    end
	end
    end

    return { :root => root, :lines => lines, :fields => fields }
end

# Strips the items of the array.
def strip_array_items(array)
    array.each_index do |array_id|
	array[array_id] = array[array_id].strip
    end
    return array
end

namespace :macrodeck do
    namespace :import do
	desc "Imports countries from COUNTRIES=path file (default is ./db/data/countries.tsv)."
	task :countries => :environment do
	    # File layout is: First line is root path second is column headers data
	    # starts at third first empty line is the end
	    ENV['COUNTRIES'] ||= "db/data/countries.tsv"
	    parsed = read_file(ENV['COUNTRIES'])
	    parsed[:lines].each do |line|
		id = line["_id"]
		root = parsed[:root].dup
		path = root << id
		title = line["title"]
		abbreviation = line["abbreviation"]

		puts "id: #{id}"
		puts "path: #{path.inspect}"
		puts "title: #{title}"
		puts "abbr: #{abbreviation}"

		country = Country.get(id) || Country.new
		country["_id"] = id
		country.created_by = "_system"
		country.updated_by = "_system"
		country.owned_by = "_system"
		country.tags = []
		country.path = path
		country.title = title
		country.abbreviation = abbreviation
		country.save if country.valid?
	    end
	end

	desc "Imports regions (states) from REGIONS=path file (no default)"
	task :regions => :environment do
	    raise "Please specify REGIONS file path on command line" if ENV['REGIONS'].nil?
	    parsed = read_file(ENV['REGIONS'])
	    parsed[:lines].each do |line|
		id = line["_id"]
		root = parsed[:root].dup
		path = root << id
		title = line["title"]
		abbreviation = line["abbreviation"]

		puts "id: #{id}"
		puts "path: #{path.inspect}"
		puts "title: #{title}"
		puts "abbr: #{abbreviation}"

		region = Region.get(id) || Region.new
		region["_id"] = id
		region.created_by = "_system"
		region.updated_by = "_system"
		region.owned_by = "_system"
		region.tags = []
		region.path = path
		region.title = title
		region.abbreviation = abbreviation
		region.save if region.valid?
	    end
	end

	desc "Imports localities (cities) from LOCALITIES=path file (no default)"
	task :localities => :environment do
	    raise "Please specify LOCALITIES file path on command line" if ENV['LOCALITIES'].nil?
	    parsed = read_file(ENV['LOCALITIES'])
	    parsed[:lines].each do |line|
		id = line["_id"]
		root = parsed[:root].dup
		path = root << id
		title = line["title"]

		puts "id: #{id}"
		puts "path: #{path.inspect}"
		puts "title: #{title}"

		locality = Locality.get(id) || Locality.new
		locality["_id"] = id
		locality.created_by = "_system"
		locality.updated_by = "_system"
		locality.owned_by = "_system"
		locality.tags = []
		locality.path = path
		locality.title = title
		locality.save if locality.valid?
	    end
	end

	desc "Imports neighborhoods from NEIGHBORHOODS=path file (no default)"
	task :neighborhoods => :environment do
	    raise "Please specify NEIGHBORHOODS file path on command line" if ENV['NEIGHBORHOODS'].nil?
	    parsed = read_file(ENV['NEIGHBORHOODS'])
	    parsed[:lines].each do |line|
		id = line["_id"]
		root = parsed[:root].dup
		path = root << id
		title = line["title"]

		puts "id: #{id}"
		puts "path: #{path.inspect}"
		puts "title: #{title}"

		neighborhood = Neighborhood.get(id) || Neighborhood.new
		neighborhood["_id"] = id
		neighborhood.created_by = "_system"
		neighborhood.updated_by = "_system"
		neighborhood.owned_by = "_system"
		neighborhood.tags = []
		neighborhood.path = path
		neighborhood.title = title
		neighborhood.save if neighborhood.valid?
	    end
	end

	desc "Imports places from PLACES=path file (no default)"
	task :places => :environment do
	    raise "Please specify PLACES file path on command line" if ENV['PLACES'].nil?
	    num_places = 0
	    parsed = read_file(ENV['PLACES'])
	    parsed[:lines].each do |line|
		id = line["_id"]
		parent = line["parent"]
		root = parsed[:root].dup

		# If parent is specified then add it to the path, otherwise don't.
		if parent != nil && parent != ""
		    path = root << parent << id
		else
		    path = root << id
		end

		title = line["title"]
		description = line["description"]
		address = line["address"]
		postal_code = line["postal_code"]
		phone_number = line["phone_number"]
		url = line["url"]
		parking = line["parking"]
		atmosphere = line["atmosphere"]
		reservations = line["reservations"]

		if line["alcohol"].nil?
		    alcohol = nil
		else
		    alcohol = strip_array_items(line["alcohol"].split(","))
		end
		if line["credit_cards_accepted"].nil?
		    credit_cards_accepted = nil
		else
		    credit_cards_accepted = strip_array_items(line["credit_cards_accepted"].split(","))
		end
		if line["fare"].nil?
		    fare = nil
		else
		    fare = strip_array_items(line["fare"].split(","))
		end
		if line["features"].nil?
		    features = nil
		else
		    features = strip_array_items(line["features"].split(","))
		end

		puts "id: #{id}"
		puts "path: #{path.inspect}"
		puts "title: #{title}"
		puts "description: #{description}"
		puts "address: #{address}"
		puts "postal_code: #{postal_code}"
		puts "phone_number: #{phone_number}"
		puts "url: #{url}"
		puts "fare: #{fare.inspect}"
		puts "features: #{features.inspect}"
		puts "parking: #{parking}"
		puts "atmosphere: #{atmosphere}"
		puts "alcohol: #{alcohol.inspect}"
		puts "cc: #{credit_cards_accepted.inspect}"
		puts "reservations: #{reservations}"

		place = Place.get(id) || Place.new
		place["_id"] = id
		place.created_by = "_system"
		place.updated_by = "_system"
		place.owned_by = "_system"
		place.tags ||= []
		place.path = path
		place.title = title
		place.description = description
		place.address = address
		place.postal_code = postal_code
		place.phone_number = phone_number
		place.url = url
		place.fare = fare
		place.features = features
		place.parking = parking
		place.atmosphere = atmosphere
		place.alcohol = alcohol
		place.credit_cards_accepted = credit_cards_accepted
		place.reservations = reservations

		if place.valid?
		    place.save
		    num_places = num_places + 1
		else
		    place.errors.full_messages.each do |msg|
			puts "!!! ERROR: #{msg}"
		    end
		    raise "Bad place!"
		end
	    end
	    puts " * - * - * - * PLACES IMPORTED: #{num_places}"
	end

	desc "Imports events from EVENTS=path file (no default)"
	task :events => :environment do
	    raise "Please specify EVENTS file path on command line" if ENV['EVENTS'].nil?
	    parsed = read_file(ENV['EVENTS'])
	    parsed[:lines].each do |line|
		id = line["_id"]
		parent_neighborhood = line["parent_neighborhood"]
		parent_place = line["parent_place"]
		root = parsed[:root].dup
		path = root

		path.push(parent_neighborhood) if !parent_neighborhood.nil? && parent_neighborhood != ""
		path.push(parent_place) if !parent_place.nil? && parent_place != ""
		path.push(id)

		title = line["title"]
		event_type = line["event_type"]
		description = line["description"]
		start_time = line["start_time"]
		end_time = line["end_time"]
		recurrence = line["recurrence"]

		start_time = Time.parse(start_time).utc.iso8601 if !start_time.nil? && start_time != ""
		end_time = Time.parse(end_time).utc.iso8601 if !end_time.nil? && end_time != ""

		puts "\nid: #{id}"
		puts "hood: #{parent_neighborhood}"
		puts "place: #{parent_place}"
		puts "path: #{path.inspect}"
		puts "type: #{event_type}"
		puts "title: #{title}"
		puts "start_time: #{start_time}"

		if start_time.nil?
		    puts line.inspect
		    puts parsed[:fields].inspect
		    puts "*** START TIME IS NIL! ***"
		else
		    event = Event.get(id) || Event.new
		    event["_id"] = id
		    event.created_by = "_system"
		    event.updated_by = "_system"
		    event.owned_by = "_system"
		    event.tags = []
		    event.path = path
		    event.title = title
		    event.event_type = event_type
		    event.description = description
		    event.start_time = start_time
		    event.end_time = end_time
		    event.recurrence = recurrence
		    event.save
		end
	    end
	end
    end
end
