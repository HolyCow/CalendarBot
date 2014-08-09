
require 'cinch'
require 'ri_cal'
require 'open-uri'
require 'tzinfo'

CHANNEL = '#' + ENV['channel']

class TimedEvents
  include Cinch::Plugin

  timer 600, :method => :get_calendar
  timer 60, :method => :upcoming_show

  def initialize(*args)
    super

    @calendar_events = nil

    get_calendar
  end

  def get_calendar
    calendar = RiCal.parse(open("https://www.google.com/calendar/ical/#{ENV['calendarid']}/public/basic.ics"))

    events = []

    calendar.first.events.each do |event|
      event = (event.occurrences({:starting => Date.today, :count => 1})).first

      if !event.nil?
        if ((event.start_time - DateTime.now) * 24 * 60).to_i < 1
          event = nil
        end
      end

      if !event.nil?
        calendar.first.events.select{|e| e.uid == event.uid }.each do |e|
          if !event.nil? && e.last_modified > event.last_modified
            event = nil
          end
        end
      end

      if event
        events << event
      end
    end

    @calendar_events = events.sort{|e1, e2| e1.start_time <=> e2.start_time}[0,10]
    debug "Calendar events collected"
  end

  match /schedule\s?(.*)/i, :method => :command_schedule

  def command_schedule(m)

    if @calendar_events.nil? || @calendar_events.count == 0
      m.user.send "Nothing is on the schedule right now"
    else
      tz = TZInfo::Timezone.get('America/New_York')

      m.user.send "Upcoming shows:"

      @calendar_events.each do |event|
        m.user.send "   #{tz.utc_to_local(event.start_time).strftime("%A, %-m/%-d/%Y")} #{tz.utc_to_local(event.start_time).strftime("%-I:%M%P EST")} - #{event.summary}"
        puts event
      end
    end
  end

  def upcoming_show
    debug "Checking for upcoming show"
    event = @calendar_events.first
    minutes = ((event.start_time - DateTime.now) * 24 * 60).to_i
    debug "Next show in #{minutes}"
    if minutes == 10
      Channel(CHANNEL).send "Approximately 10 minutes until #{event.summary}"
    end
  end
end

bot = Cinch::Bot.new do

  configure do |c|
    c.server   = 'irc.freenode.org'
    c.channels = ['#' + ENV['channel']]
    c.nick = ENV['botname']
    c.plugins.plugins = [TimedEvents]
  end

end

bot.start
