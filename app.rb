require 'rest-client'
require "sinatra"
require "json"
require 'date'



class FeedEmbedApp < Sinatra::Base


  FCFP_TRUSTID = '39aa8f9d-e5d6-4b73-b8e4-3fff35990d25'
  ZEPHYR_TRUSTID = '43128308-697d-4ac6-be24-4b5b1edfbeec'
  VINTAGE_TRUSTID = '0b747c76-b4af-4ba4-8940-3c827621c06f'

  EVENT_URL = 'https://www.steamboat.com/events/feed'
  TRUSTYOU_URL = 'https://api.trustyou.com/hotels/'

  TRUST_TYPE = '/seal.json'

  get '/events' do
    @data = JSON.parse(RestClient.get EVENT_URL)
    @events = @data['events'][0]['Events']
    @resortTitle = 'Winter Park Resort'
    erb :event  
  end

  get '/winterpark/lodging/reviews' do
    trust_id = params[:trust_id]
    @data = JSON.parse(RestClient.get TRUSTYOU_URL + trust_id + TRUST_TYPE)
    @data = @data['response']
    @resortTitle = 'Winter Park Resort'
    @score = (@data['score'].to_f * 5) / 100
    erb :reviews  
  end


  get '/' do
    erb :index
  end
end