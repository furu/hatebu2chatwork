require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?

get '/' do
  'hi, I am the hatebu2chatwork.'
end

post '/' do
end

