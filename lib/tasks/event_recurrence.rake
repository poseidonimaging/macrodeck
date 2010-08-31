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
	    if ["weekly", "monthly", "yearly", "monthly_nth_nday"].include?(event.recurrence)
		while event_concluded?(event)
		    dtstart = Time.parse(event.start_time)
		    dtend = event.end_time.nil? ? nil : Time.parse(event.end_time)

		    case event.recurrence
		    when "weekly" then
			dtstart = 1.week.since dtstart
			dtend = 1.week.since dtend unless dtend.nil?
		    when "monthly" then
			dtstart = 1.month.since dtstart
			dtend = 1.month.since dtend unless dtend.nil?
		    when "yearly" then
			dtstart = 1.year.since dtstart
			dtend = 1.year.since dtend unless dtend.nil?
		    when "monthly_nth_nday" then
			dtstart = 28.days.since dtstart # 28 days = 4 weeks = causes it to fall on same day.
			dtend = 28.days.since dtend unless dtend.nil?
		    # Services had another every_n_days which was not really used.
		    end

		    # Save values.
		    event.start_time = dtstart.getutc.iso8601
		    event.end_time = dtend.getutc.iso8601 unless dtend.nil?
		    puts "Updating Event <#{event.id}> to start at #{event.start_time}"
		    event.save
		end
	    end
	end
    end
end