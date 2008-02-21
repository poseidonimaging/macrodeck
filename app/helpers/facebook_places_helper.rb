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
			table_items = []
			p_sample = patrons[0..14]
			p_sample.each do |p|
				if p.facebook_uid != nil && p.facebook_uid.to_i > 0 
					table_items << "<fb:name uid=\"#{p.facebook_uid}\" capitalize=\"true\" shownetwork=\"true\" ifcantsee=\"Facebook User ##{p.facebook_uid}\" /><br />"
				elsif p.name != nil
					table_items << "#{p.name} (MacroDeck User)"
				end
			end
			return threecol_layout(table_items)
		end

end
