require 'rest-client'
require 'sinatra'
require 'json'
require 'date'
require 'rufus-scheduler'

configure :development do
  require 'dotenv/load'
end

#Scheduled Behavior
scheduler = Rufus::Scheduler.new

scheduler.every '1h' do
  EventFeedWriter.new.read_feed
  LodgingFeedWriter.new.read_feed
  puts 'Feed Update Success' 
  puts ' '
  print 'Event Feed last updated: ', File.mtime(EventFeedWriter::EVENT_FILE_LOC)
  puts ' '
  print 'Lodging Feed last updated: ', File.mtime(EventFeedWriter::EVENT_FILE_LOC)
end


EVENT_URL = ENV['EVENT_URL']
TRUSTYOU_URL = ENV['TRUST_YOU']
LODGING_URL = ENV['LODGING_URL']

TRUST_SEAL = '/seal.json'


class EventFeedWriter
  EVENT_FILE_LOC = 'feeds/event-feed.json'
  
  def read_feed
    event_feed = File.new(EVENT_FILE_LOC, 'w+')
    event_feed.close

    File.open(event_feed, 'w') {
      |file| file.write(
        RestClient.get EVENT_URL
      )
    }
  end
end

# Not DRY as I expect the future reading methods to diverge in access logic
class LodgingFeedWriter
  EVENT_FILE_LOC = 'feeds/lodging-feed.json'
  
  def read_feed
    event_feed = File.new(EVENT_FILE_LOC, 'w+')
    event_feed.close

    File.open(event_feed, 'w') {
      |file| file.write(
        RestClient.get LODGING_URL
      )
    }
  end
end


class FeedEmbedApp < Sinatra::Base
  
  # Full Winter Park Event Feed from Sitecore
  get '/events' do
    resort_id = params[:resort].to_i
    begin
      @data = JSON.parse(
        File.read(
          EventFeedWriter::EVENT_FILE_LOC
        )
      )
    rescue
      @data = JSON.parse(RestClient.get EVENT_URL)
      puts "Event Feed Rescued"
    end

    @events = @data['events'][resort_id]
    @resortTitle = 'Winter Park Resort Events'
    erb :event  
  end


  # Full Winter Park Lodging Feed from Sitecore
  get '/winterpark/lodging' do
    begin 
      @data = JSON.parse(
        File.read(
          LodgingFeedWriter::EVENT_FILE_LOC
        )
      )
    rescue
      @data = JSON.parse(RestClient.get LODGING_URL)
      puts "Lodging Feed Rescued"
    end

    @lodging = @data['Lodging'][3]['Lodgings']
    @resortTitle = 'Winter Park Resort Lodging'
    erb :lodging  
  end

# Reviews from TrustYou, we pay them so I don't might slamming their feed plus their update would likely be better than Heroku's.

  get '/winterpark/lodging/reviews' do
    trust_id = params[:trust_id]
    @data = JSON.parse(RestClient.get TRUSTYOU_URL + trust_id + TRUST_SEAL)
    @data = @data['response']
    @resortTitle = 'Winter Park Resort Reviews -' + @data['name']
    @score = ((@data['score'].to_f * 5) / 100).round(1)
    erb :reviews  
  end

  get '/' do
    erb :index
  end
end