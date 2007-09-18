class PlacesCategoryHierarchy < ActiveRecord::Migration
  def self.up
	# This migration creates a root category called "Places" and populates it with
	# "United States" and then populates United States with all of our states.
	
	places = DataService.createCategory(:title => "Places", :url_part => "places", :description => "MacroDeck Places")
	usa = places.createChild(:title = > "United States", :url_part => "us", :description => "Places in the United States")
	
	# States.
	usa.createChild(:title => "Alabama",	:url_part => "al")
	usa.createChild(:title => "Alaska",		:url_part => "ak")
	usa.createChild(:title => "Arizona",	:url_part => "az")
	usa.createChild(:title => "Arkansas",	:url_part => "ar")
	usa.createChild(:title => "California",	:url_part => "ca")
	usa.createChild(:title => "Colorado",	:url_part => "co")
	usa.createChild(:title => "Connecticut",:url_part => "ct")
	usa.createChild(:title => "Delaware",	:url_part => "de")
	usa.createChild(:title => "Florida",	:url_part => "fl")
	usa.createChild(:title => "Georgia",	:url_part => "ga")
	usa.createChild(:title => "Hawaii",		:url_part => "hi")
	usa.createChild(:title => "Idaho",		:url_part => "id")
	usa.createChild(:title => "Illinois",	:url_part => "il")
	usa.createChild(:title => "Indiana",	:url_part => "in")
	usa.createChild(:title => "Iowa",		:url_part => "ia")
	usa.createChild(:title => "Kansas",		:url_part => "ks")
	usa.createChild(:title => "Kentucky",	:url_part => "ky")
	usa.createChild(:title => "Louisiana",	:url_part => "la")
	usa.createChild(:title => "Maine",		:url_part => "me")
	usa.createChild(:title => "Maryland",	:url_part => "md")
	usa.createChild(:title => "Massachusetts",:url_part => "ma")
	usa.createChild(:title => "Michigan",	:url_part => "mi")
	usa.createChild(:title => "Minnesota",	:url_part => "mn")
	usa.createChild(:title => "Mississippi",:url_part => "ms")
	usa.createChild(:title => "Missouri",	:url_part => "mo")
	usa.createChild(:title => "Montana",	:url_part => "mt")
	usa.createChild(:title => "Nebraska",	:url_part => "ne")
	usa.createChild(:title => "Nevada",		:url_part => "nv")
	usa.createChild(:title => "New Hampshire",:url_part => "nh")
	usa.createChild(:title => "New Jersey",	:url_part => "nj")
	usa.createChild(:title => "New Mexico",	:url_part => "nm")
	usa.createChild(:title => "New York",	:url_part => "ny")
	usa.createChild(:title => "North Carolina",:url_part => "nc")
	usa.createChild(:title => "North Dakota",:url_part => "nd")
	usa.createChild(:title => "Ohio",		:url_part => "oh")
	usa.createChild(:title => "Oklahoma",	:url_part => "ok")
	usa.createChild(:title => "Oregon",		:url_part => "or")
	usa.createChild(:title => "Pennsylvania",:url_part => "pa")
	usa.createChild(:title => "Rhode Island",:url_part => "ri")
	usa.createChild(:title => "South Carolina", :url_part => "sc")
	usa.createChild(:title => "South Dakota",:url_part => "sd")
	usa.createChild(:title => "Tennessee",	:url_part => "tn")
	usa.createChild(:title => "Texas",		:url_part => "tx")
	usa.createChild(:title => "Utah",		:url_part => "ut")
	usa.createChild(:title => "Vermont",	:url_part => "vt")
	usa.createChild(:title => "Virginia",	:url_part => "va")
	usa.createChild(:title => "Washington",	:url_part => "wa")
	usa.createChild(:title => "West Virginia",:url_part => "wv")
	usa.createChild(:title => "Wisconsin",	:url_part => "wi")
	usa.createChild(:title => "Wyoming",	:url_part => "wy")
  end

  def self.down
  end
end
