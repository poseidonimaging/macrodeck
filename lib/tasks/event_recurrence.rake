# Returns true if the times passed in are "over"
def concluded?(dtstart, dtend)
    if (dtstart && dtend) && dtend < Time.new
	return true
    elsif (dtstart && !dtend) && (dtstart + 6.hours) < Time.new
	return true
    else
	return false
    end
end

# Same as previous function but it works on an event.
def event_concluded?(event)
    # Check if event is concluded.
    dtstart = Time.parse(event.start_time)
    dtend = event.end_time.nil? ? nil : Time.parse(event.end_time)
    return concluded?(dtstart, dtend)
end

namespace :macrodeck do
    # TODO: Use a view to only pull the events which need processed (past events
    # with something besides null/none in recurrence)
    desc "Runs through the events and processes their recurrence"
    task :process_recurrence => :environment do
	Event.all.each do |event|
	    # (mostly ripped out of Services, sue me)
	end
    end
end