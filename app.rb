require 'rest-client'
require "sinatra"
require "json"
require 'date'
#require 'dotenv/load'



class FeedEmbedApp < Sinatra::Base

  EVENT_URL = ENV['EVENT_URL']
  TRUSTYOU_URL = ENV['TRUST_YOU']
  LODGING_URL = ENV['LODGING_URL']

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
    @resortTitle = 'Winter Park Resort Reviews ' + @data['name']
    @score = ((@data['score'].to_f * 5) / 100).round(1)
    erb :reviews  
  end

  get '/lodging' do
    @data = JSON.parse(RestClient.get LODGING_URL)
    @lodging = @data['Lodging'][3]['Lodgings']
    @resortTitle = 'Winter Park Resort Lodging'
    erb :lodging  
  end


  get '/' do
    erb :index
  end
end