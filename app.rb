require 'rest-client'
require 'sinatra'
require 'json'
require 'date'
require 'rufus-scheduler'

configure :development do
  require 'dotenv/load'
end

#Scheduled Behavior
event_scheduler = Rufus::Scheduler.new
lodging_scheduler = Rufus::Scheduler.new

event_scheduler.every '10m' do
  EventFeedWriter.new.read_feed
  puts 'Event Feed last updated: ', File.mtime(EventFeedWriter::EVENT_FILE_LOC)
end

lodging_scheduler.every '25m' do
  LodgingFeedWriter.new.read_feed
  puts 'Lodging Feed last updated: ', File.mtime(EventFeedWriter::EVENT_FILE_LOC)
end

EVENT_URL = ENV['EVENT_URL']
TRUSTYOU_URL = ENV['TRUST_YOU']
LODGING_URL = ENV['LODGING_URL']

TRUST_SEAL = '/seal.json'

RESORT_UNIQUE_ID = Hash[
  0 => "Winter Park Resort",
  1 => "Tremblant Resort",
  2 => "Steamboat Resort",
  3 => "Snowshoe Resort",
  4 => "Stratton Mountain",
  5 => "Blue Mountain" 
]

RESORT_LODGING_UNIQUE_ID = Hash[
  0 => "Blue Mountain",
  1 => "Stratton Mountain",
  2 => "Steamboat Resort",
  3 => "Winter Park Resort",
  4 => "Snowshoe Resort",
  5 => "Tremblant" 
]
 

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
    @resortTitle = RESORT_UNIQUE_ID[resort_id]
    erb :event  
  end


  # Full Winter Park Lodging Feed from Sitecore
  get '/lodging' do
    resort_id = params[:resort].to_i
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

    @lodging = @data['Lodging'][resort_id]
    @resortTitle = RESORT_LODGING_UNIQUE_ID[resort_id]
    erb :lodging  
  end

# Reviews from TrustYou, we pay them so I don't might slamming their feed plus their update would likely be better than Heroku's.

  get '/lodging/reviews' do
    trust_id = params[:trust_id]
    resort_id = params[:resort].to_i
    @data = JSON.parse(RestClient.get TRUSTYOU_URL + trust_id + TRUST_SEAL)
    @data = @data['response']
    @resortTitle = RESORT_UNIQUE_ID[resort_id] + ' Reviews -' + @data['name']
    @score = ((@data['score'].to_f * 5) / 100).round(1)
    erb :reviews  
  
  end

  get '/' do
    erb :index
  end
end