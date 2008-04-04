module FacebookPlacesHelper

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

		# Makes a "Patrons" three column thingy.
		def patron_table(patrons)
			table_items = ""
			p_sample = patrons[0..14]
			p_sample.each do |p|
				if p.facebook_uid != nil && p.facebook_uid.to_i > 0 
					table_items << "<fb:profile-pic uid=\"#{p.facebook_uid}\"linked=\"true\" size=\"square\" />"
				end
			end
			return table_items
		end

end
