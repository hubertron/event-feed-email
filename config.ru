require 'bundler'
Bundler.require

require './app'

run EventFeedWriter
run LodgingFeedWriter
run FeedEmbedApp