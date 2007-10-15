module FacebookPlacesHelper

		# This method takes a string and returns a suitable URL version.
		def url_sanitize(str)
			return str.chomp.strip.downcase.gsub(/[^0-9A-Za-z_\-\s]/, "").gsub(" ", "-")
		end

		# This method takes a network (response object from fbsession) and
		# returns a hash containing network information.
		def get_network_info(network)
			h = Hash.new
			h[:country] = "US"
			h[:state] = network.name.split(",")[-1].chomp.strip
			h[:city] = network.name.split(",")[0].chomp.strip
			h[:name] = network.name
			h[:nid] = network.nid
			return h
		end
end
