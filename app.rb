require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'net/https'
require 'uri'

abort 'Please set HatebuWebHookKey environment variable.' unless ENV.has_key?('HatebuWebHookKey')
abort 'Please set ChatWorkRoomID environment variable.' unless ENV.has_key?('ChatWorkRoomID')
abort 'Please set ChatWorkToken environment variable.' unless ENV.has_key?('ChatWorkToken')

get '/' do
  'hi, I am the hatebu2chatwork.'
end

post '/' do
  halt 'invalid key' unless params['key'] == ENV['HatebuWebHookKey']
  halt 'invalid status' unless params['status'] == 'add'
  halt 'do not bypass' unless params['comment'] =~ /\[_\]/

  body = "[info][title]#{params['title']}[/title]#{params['url']}[/info]"

  endpoint = "https://api.chatwork.com/v1/rooms/#{ENV['ChatWorkRoomID']}/messages"
  header = {'Content-Type' => 'application/x-www-form-urlencoded', 'X-ChatWorkToken' => ENV['ChatWorkToken']}

  request = Net::HTTP::Post.new(endpoint, header)
  request.body = "body=#{body}"

  https = Net::HTTP.new('api.chatwork.com', 443)
  https.use_ssl = true
  https.verify_mode = OpenSSL::SSL::VERIFY_NONE

  https.start do |client|
    response = client.request(request)

    if response.code == '200'
      'OK'
    end
  end
end

