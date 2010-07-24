def read_file(file_name)
	file = File.new(file_name, "r")
	line_number = 0
	root = ""
	done = false
	fields = []
	lines = []

	while (line = file.gets)
		line_number = line_number + 1
		if line_number == 1
			root = line.strip.gsub(/^"/, "").gsub(/"$/, "").gsub('""', '"')
			root = eval(root.to_s)
		elsif line_number == 2
			fields = line.strip.split("\t")
			fields.each_index do |field_id|
				fields[field_id] = fields[field_id].split(" ")[0]
			end
		elsif line_number > 2 && !done
			line_arr = line.strip.split("\t")
			line_hsh = {}
			if line_arr == []
				done = true
			else
				line_arr.each_index do |item_id|
					line_hsh[fields[item_id]] = line_arr[item_id].gsub(/^"/, "").gsub(/"$/, "").gsub('""', '"').strip
					line_hsh[fields[item_id]] = nil if line_hsh[fields[item_id]].empty?
				end
				lines << line_hsh
			end
		end
	end

	return { :root => root, :lines => lines }
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
			# File layout is:
			# First line is root path
			# second is column headers
			# data starts at third
			# first empty line is the end
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
				country.save
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
				region.save
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
				locality.save
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
				neighborhood.save
			end
		end

		desc "Imports places from PLACES=path file (no default)"
		task :places => :environment do
			raise "Please specify PLACES file path on command line" if ENV['PLACES'].nil?
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
				place.save
			end
		end
	end
end
