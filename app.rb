require 'rest-client'
require "sinatra"
require "json"
require 'date'




class FeedEmbedApp < Sinatra::Base

  EVENT_URL = 'https://www.steamboat.com/events/feed'
  TRUSTYOU_URL = 'https://api.trustyou.com/hotels/'
  LODGING_URL = 'https://www.steamboat.com/shared/Lodgingfeed/get'

  TRUST_SEAL = '/seal.json'

  get '/events' do
    @data = JSON.parse(RestClient.get EVENT_URL)
    @events = @data['events'][0]['Events']
    @resortTitle = 'Winter Park Resort'
    erb :event  
  end

  get '/winterpark/lodging/reviews' do
    trust_id = params[:trust_id]
    @data = JSON.parse(RestClient.get TRUSTYOU_URL + trust_id + TRUST_SEAL)
    @data = @data['response']
    @resortTitle = 'Winter Park Resort'
    @score = ((@data['score'].to_f * 5) / 100).round(1)
    erb :reviews  
  end

  get '/lodging' do
    @data = JSON.parse(RestClient.get LODGING_URL)
    @lodging = @data['Lodging'][3]['Lodgings']
    @resortTitle = 'Winter Park Resort'
    erb :lodging  
  end


  get '/' do
    erb :index
  end
end