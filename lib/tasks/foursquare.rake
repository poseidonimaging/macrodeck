gem "foursquare"
require "foursquare2"

FSQ_CLIENT_ID	    = "OYKYCGLQROAYWN4WYURTJVCNBVNRNY2VONHJG3QLRMBCZ3DE"
FSQ_CLIENT_SECRET   = "O4JHI3SHNKHO4IRISUIFVJFFFFKB3XYOM2EBETZQA2INDJOP"
FSQ_REDIRECT_URI    = "http://intranet.ignition-project.com:3000/"

POSTAL_SUFFIXES = [ "aly", "anx", "arc", "ave",
		    "byu", "bch", "bnd", "blf", "blfs", "btm", "blvd", "br", "brg", "brk", "brks", "bg", "bgs", "byp",
		    "cp", "cyn", "cpe", "cswy", "ctr", "ctrs", "cir", "cirs", "clf", "clfs", "clb", "cmn", "cmns", "cor", "cors", "crse", "ct", "cts", "cv", "cvs", "crk", "cres", "crst", "xing", "xrd", "xrds", "curv",
		    "dl", "dm", "dv", "dr", "drs",
		    "est", "ests", "expy", "ext", "exts",
		    "fall", "fls", "fry", "fld", "flds", "flt", "flts", "frd", "frds", "frst", "frg", "frgs", "frk", "frks", "ft", "fwy",
		    "gdn", "gdns", "gtwy", "gln", "glns", "grn", "grns", "grv", "grvs",
		    "hbr", "hbrs", "hvn", "hts", "hwy", "hl", "hls", "holw",
		    "inlt", "is", "iss", "isle",
		    "jct", "jcts",
		    "ky", "kys", "knl", "knls",
		    "lk", "lks", "land", "lndg", "ln", "lgt", "lgts", "lf", "lck", "lcks", "ldg", "loop",
		    "mall", "mnr", "mnrs", "mdw", "mdws", "mews", "ml", "mls", "msn", "mtwy", "mt", "mtn", "mtns",
		    "nck",
		    "orch", "oval", "opas",
		    "park", "pkwy", "pass", "psge", "path", "pike", "pne", "pnes", "pl", "pln", "plns", "plz", "pt", "pts", "prt", "prts", "pr",
		    "radl", "ramp", "rnch", "rpd", "rpds", "rst", "rdg", "rdgs", "riv", "rd", "rds", "rte", "row", "rue", "run",
		    "shl", "shls", "shr", "shrs", "skwy", "spg", "spgs", "spur", "sq", "sqs", "sta", "stra", "strm", "st", "sts", "smt",
		    "ter", "trwy", "trce", "trak", "trfy", "trl", "trlr", "trlr", "tunl", "tpke",
		    "upas", "un", "uns",
		    "vly", "vlys", "via", "vw", "vws", "vlg", "vlgs", "vl", "vis",
		    "walk", "wall", "way", "ways", "wl", "wls",
		    "apt", "bsmt", "bldg", "dept", "fl", "frnt", "hngr", "key", "lbby", "lot", "lowr", "ofc", "ph", "pier", "rear", "rm", "side", "slip", "spc", "stop", "ste", "trlr", "unit", "uppr",
		    "n", "s", "e", "w", "ne", "nw", "se", "sw",
		    "north", "south", "east", "west", "northeast", "northwest", "southeast", "southwest",
		    "suite", "street", "circle", "drive", "road", "boulevard"
		  ]

namespace :macrodeck do
    namespace :foursquare do
	desc "Get tips from Foursquare"
	task :tips => :environment do
	    # Doing this anonymously means we don't need to redirect or get any tokens.
	    puts "Initializing OAuth..."
	    oauth = Foursquare2::OAuth2.new(FSQ_CLIENT_ID, FSQ_CLIENT_SECRET, FSQ_REDIRECT_URI)
	    puts "Initializing Foursquare2..."
	    fsq = Foursquare2::Base.new(oauth)

	    places = Place.view("by_foursquare_venue_id", :reduce => false, :include_docs => false)
	    if places["rows"]
		places["rows"].each do |p|
		    fsq_id = p["key"]
		    doc_id = p["id"]
		    
		    # Format: [text, { :foursquare_user_id => xxx, :name => xxx, :photo_url => xxx }]
		    place_tips = []

		    tips = fsq.venues_tips(:id => fsq_id)
		    puts "#{fsq_id} #{doc_id}"

		    # Get tips from Foursquare.
		    if tips["tips"] && tips["tips"]["items"] && tips["tips"]["items"].length > 0
			tips["tips"]["items"].each do |t|
			    place_tips << [ t["text"].strip,
					    {
						:foursquare_tip_id => t["id"],
						:foursquare_user_id => t["user"]["id"],
						:name => "#{t["user"]["firstName"]} #{t["user"]["lastName"]}".strip,
						:photo_url => t["user"]["photo"],
						:created_at => Time.at(t["createdAt"]).getutc.iso8601
					    }
					  ]
			    puts "  #{t["user"]["firstName"]} #{t["user"]["lastName"]}: #{t["text"]}"
			end
		    end

		    place_obj = Place.get(doc_id)
		    place_obj.tips = place_tips
		    place_obj.updated_by = "_system/FoursquareTips"
		    place_obj.save

		end
	    end
	end

	desc "Clears venue IDs"
	task :clear_venue_ids => :environment do
	    places = Place.all
	    places.each do |p|
		p.update_attributes "foursquare_venue_id" => nil
	    end
	end

	desc "Goes through places and sets their Foursquare venue IDs"
	task :venue_ids => :environment do
	    # Doing this anonymously means we don't need to redirect or get any tokens.
	    puts "Initializing OAuth..."
	    oauth = Foursquare2::OAuth2.new(FSQ_CLIENT_ID, FSQ_CLIENT_SECRET, FSQ_REDIRECT_URI)
	    puts "Initializing Foursquare2..."
	    fsq = Foursquare2::Base.new(oauth)

	    places = Place.view("by_missing_foursquare_venue_id", :reduce => false, :include_docs => true)
	    places.each do |p|
		if p.geo && p.foursquare_venue_id.nil?
		    puts "Looking up #{p.title} on Foursquare..."
		    result = fsq.venues_search(:ll => p.geo.join(","), :query => p.title, :limit => 10)
		    if result["groups"] && result["groups"].length > 0 && result["groups"][0]["name"] == "Matching Places"
			result["groups"][0]["items"].each do |fsq_place|
			    if fsq_place["location"] && fsq_place["location"]["address"]
				# clean up the addresses by removing all non-alphanumeric characters and postal abbreviations.
				place_address = p.address.dup
				fsq_address = fsq_place["location"]["address"].dup

				place_address.gsub!(/[^ A-Za-z0-9]/, "")
				fsq_address.gsub!(/[^ A-Za-z0-9]/, "")

				place_address = place_address.split(" ")
				fsq_address = fsq_address.split(" ")

				place_address.collect! do |p_addrpart|
				    if POSTAL_SUFFIXES.include?(p_addrpart.downcase)
					nil
				    else
					p_addrpart
				    end
				end

				fsq_address.collect! do |fsq_addrpart|
				    if POSTAL_SUFFIXES.include?(fsq_addrpart.downcase)
					nil
				    else
					fsq_addrpart
				    end
				end

				if place_address.compact.join(" ").downcase == fsq_address.compact.join(" ").downcase
				    puts "[#{p.id}] #{p.title} 4sq venueid = #{fsq_place["id"]}"
				    p.foursquare_venue_id = fsq_place["id"]
				    p.updated_by = "_system/FoursquareVenueIds"
				    p.save
				else
				    puts "  #{place_address.compact.join(' ')} || #{fsq_address.compact.join(' ')}"
				end
			    end
			end
		    end
		end
	    end
	end
    end
end