require 'rest-client'
require "sinatra"
require "json"
require 'date'
require 'rufus-scheduler'

configure :development do
  require 'dotenv/load'
end

#Scheduled Behavior
scheduler = Rufus::Scheduler.new

scheduler.every '4s' do
  EventFeedWriter.new.read_feed
  LodgingFeedWriter.new.read_feed
  puts "Feed Update Success"
  
end




EVENT_URL = ENV['EVENT_URL']
TRUSTYOU_URL = ENV['TRUST_YOU']
LODGING_URL = ENV['LODGING_URL']

TRUST_SEAL = '/seal.json'


class EventFeedWriter
  EVENT_FILE_LOC = "event-feed.json"
  
  def read_feed
    event_feed = File.new(EVENT_FILE_LOC, "w+")
    event_feed.close

    File.open(event_feed, "w") {
      |file| file.write(
        RestClient.get EVENT_URL
      )
    }
  end
end

# Not DRY as I expect the future reading methods to diverge in access logic
class LodgingFeedWriter
  EVENT_FILE_LOC = "lodging-feed.json"
  
  def read_feed
    event_feed = File.new(EVENT_FILE_LOC, "w+")
    event_feed.close

    File.open(event_feed, "w") {
      |file| file.write(
        RestClient.get LODGING_URL
      )
    }
  end
end


class FeedEmbedApp < Sinatra::Base

  get '/events' do
    @data = JSON.parse(
      File.read(
        EventFeedWriter::EVENT_FILE_LOC
        )
        )
    @events = @data['events'][0]['Events']
    @resortTitle = 'Winter Park Resort'
    erb :event  
  end

  get '/winterpark/lodging/reviews' do
    trust_id = params[:trust_id]
    @data = JSON.parse(RestClient.get TRUSTYOU_URL + trust_id + TRUST_SEAL)
    @data = @data['response']
    @resortTitle = 'Winter Park Resort Reviews ' + @data['name']
    @score = ((@data['score'].to_f * 5) / 100).round(1)
    erb :reviews  
  end

  get '/lodging' do
    @data = JSON.parse(
      File.read(
        LodgingFeedWriter::EVENT_FILE_LOC
        )
        )
    @lodging = @data['Lodging'][3]['Lodgings']
    @resortTitle = 'Winter Park Resort Lodging'
    erb :lodging  
  end


  get '/' do
    erb :index
  end
end