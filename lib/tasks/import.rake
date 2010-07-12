def read_file(file_name)
	file = File.new(file_name, "r")
	line_number = 0
	root = ""
	done = false
	lines = []

	while (line = file.gets)
		line_number = line_number + 1
		if line_number == 1
			root = line
			root = root.strip
			root = root.gsub(/^"/, "")
			root = root.gsub(/"$/, "")
			root = eval(root.to_s)
		elsif line_number > 2 && !done
			line_arr = line.split("\t")
			if line_arr == []
				done = true
			else
				lines << line_arr
			end
		end
	end

	return { :root => root, :lines => lines }
end

namespace :macrodeck do
	desc "Loads countries from COUNTRIES=path file."
	task :load_countries do
		# File layout is:
		# First line is root path
		# second is column headers
		# data starts at third
		# first empty line is the end
		ENV['COUNTRIES'] ||= "db/data/countries.tsv"
		parsed = read_file(ENV['COUNTRIES'])
		p parsed

	end
end
