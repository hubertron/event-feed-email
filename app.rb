require 'rest-client'
require "sinatra"
require "json"
require 'date'


class MySinatraApp < Sinatra::Base

  EVENT_URL = 'https://www.steamboat.com/events/feed'

 get '/events' do
    @data = JSON.parse(RestClient.get EVENT_URL)
    @events = @data['events'][0]['Events']
    @resortTitle = 'Winter Park Resort'
    erb :event  
  end

  get '/' do
    erb :index
  end
end