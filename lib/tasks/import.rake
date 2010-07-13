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
			root = line.strip.gsub(/^"/, "").gsub(/"$/, "")
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
		desc "Imports countries from COUNTRIES=path file."
		task :countries do
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
				path = root << line["_id"]
				title = line["title"]
				abbreviation = line["abbreviation"]
				puts "id: #{id}"
				puts "path: #{path.inspect}"
				puts "title: #{title}"
				puts "abbr: #{abbreviation}"
			end
		end
	end
end
