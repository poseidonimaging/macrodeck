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
		elsif line_number > 2 && !done
			line_arr = line.strip.split("\t")
			line_hsh = {}
			if line_arr == []
				done = true
			else
				line_arr.each_index do |item_id|
					line_hsh[fields[item_id]] = line_arr[item_id]
				end
				lines << line_hsh
			end
		end
	end

	return { :root => root, :lines => lines }
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

		desc "Imports neighborhoods NEIGHBORHOODS=path file (no default)"
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
	end
end
