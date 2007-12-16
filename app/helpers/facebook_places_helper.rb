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

		# A URL helper that will hopefully override the default fbplaces_url and let you
		# link to crap easier.
		#
		# options_hash possible values:
		#   :action => (any action you wish... used in ../action/us/ok/tulsa/
		#   :country => (two-letter country code)
		#   :state => (two-letter state)
		#   :city => City object
		#   :place => Place object
		def fbplaces_url(options = {})
			url = "#{PLACES_FBURL}/"
			if options[:action] != nil && options[:action] != ""
				url << "#{url_sanitize(options[:action].to_s)}/"
			end
			if options[:country] != nil && options[:country] != ""
				url << "#{url_sanitize(options[:country])}/"
			end
			if options[:state] != nil && options[:state] != ""
				url << "#{url_sanitize(options[:state])}/"
			end
			if options[:city] != nil && options[:city] != ""
				url << "#{url_sanitize(options[:city])}/"
			end
			if options[:place] != nil && options[:place] != ""
				url << "#{url_sanitize(options[:place])}/"
			end
			return url
		end
end
