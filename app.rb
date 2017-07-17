require 'rest-client'
require "sinatra"
require "json"
require 'date'


class MySinatraApp < Sinatra::Base

  EVENT_URL = 'https://www.steamboat.com/events/feed'
  TRUSTYOU_URL = 'https://api.trustyou.com/hotels/39aa8f9d-e5d6-4b73-b8e4-3fff35990d25/seal.json'

 get '/events' do
    @data = JSON.parse(RestClient.get EVENT_URL)
    @events = @data['events'][0]['Events']
    @resortTitle = 'Winter Park Resort'
    erb :event  
  end

  get '/lodging' do
    @data = JSON.parse(RestClient.get TRUSTYOU_URL)
    @data = @data['response']
    @resortTitle = 'Winter Park Resort'
    erb :reviews  
  end

  get '/' do
    erb :index
  end
end