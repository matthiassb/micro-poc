require 'sinatra'
require 'json'

class LocationsApp < Sinatra::Base
  get '/locations' do
    content_type :json
    { message: 'Hello World - From Locations (Ruby)' }.to_json
  end
end

def handler(event:, context:)
  LocationsApp.call(event)
end
