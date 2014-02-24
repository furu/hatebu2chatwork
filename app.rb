require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'net/https'
require 'uri'
require 'json'

abort 'Please set HatebuWebHookKey environment variable.' unless ENV.has_key?('HatebuWebHookKey')
abort 'Please set ChatWorkRoomID environment variable.' unless ENV.has_key?('ChatWorkRoomID')
abort 'Please set ChatWorkToken environment variable.' unless ENV.has_key?('ChatWorkToken')

get '/' do
  'hi, I am the hatebu2chatwork.'
end

post '/' do
  halt 'invalid key' unless params['key'] == ENV['HatebuWebHookKey']
  halt 'invalid status' unless params['status'] == 'add'
  halt 'do not bypass' unless params['comment'] =~ /\[_\]/ # TBD: post bookmarked info to chatwork when tags contain underscore

  Net::HTTP.start('api.chatwork.com', Net::HTTP.https_default_port, use_ssl: true) do |https|
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    response = https.post(
      "/v1/rooms/#{ENV['ChatWorkRoomID']}/messages",
      "body=[info][title]#{params['title']}[/title]#{params['url']}[/info]",
      { 'X-ChatWorkToken' => ENV['ChatWorkToken'] }
    )

    message_id = JSON.parse(response.body)['message_id']

    if response.code == '200'
      "Success! Message(id: #{message_id}) is posted."
    else
      "Failed! Message(id: #{message_id}) is not posted."
    end
  end
end

