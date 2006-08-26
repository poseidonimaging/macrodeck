# MacroDeck Services Remote Data Updater
# (C) 2006 Keith Gable <ziggy@ignition-project.com>
#
# Released under a modified GPL license. See LICENSE.

# Start DataService
require 'lib/services.rb'
require 'activerecord'
Services.startService "data_service"

# Load RSS feed reader
require 'rss/0.9'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/dublincore'
require 'rss/syndication'
require 'rss/content'
require 'rss/trackback'
require 'rss/image'

# Load HTTP client
require 'net/http'
require 'uri'

# Line Feed Constant
NEWLINE = "\r\n"

# Version Number
VERSION = "0.3.20060826"

# Clears the remote sources for the specified UUID
# This should be called when processing new entries.
def clear_remote_sources(uuid)
	ditems = DataItem.find(:all, :conditions => ["remote_data = 1 AND sourceid = ?", uuid])
	ditems.each do |ditem|
		ditem.destroy
	end
	dgroups = DataGroup.find(:all, :conditions => ["remote_data = 1 AND sourceid = ?", uuid])
	dgroups.each do |dgroup|
		dgroup.destroy
	end
	return true
end

def insert_rss(rss_content)
end

def main
	puts "MacroDeck Services Remote Data Updater" + NEWLINE
	puts "======================================" + NEWLINE
	
	sources = DataSource.find(:all)
	puts " * #{sources.length} sources exist in the database." + NEWLINE
	sources.each do |source|
		if (Time.now.to_i - source.updated) >= source.update_interval
			# The update interval has passed; fetch the content file.
			puts " ! #{source.title} is out of date, updating..." + NEWLINE
			url = URI.parse(source.uri)
			resource = Net::HTTP.start(url.host, url.port) do |http|
				http.get(url.path, {
					"Accept" => "*/*",
					"User-Agent" => "MacroDeckFeedUpdater/" + VERSION + " (+http://www.macrodeck.com/)"
					})
			end
			case source.file_type.downcase
				when "rss"
					insert_rss(resource.body)
			end
		end
	end
end

# Run the program
main