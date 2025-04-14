require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/activerecord'
require 'json'
require 'rack'
require 'base64'
require_relative 'app/models/location'

class LocationsApp < Sinatra::Base
  
  # Configure Sinatra
  register Sinatra::ActiveRecordExtension
  
  configure do
    set :show_exceptions, false
    set :raise_errors, false
    set :dump_errors, false
    set :database_file, File.expand_path('../config/database.yml', __FILE__)
  end

  # Error handling
  error do
    json error: env['sinatra.error'].message
  end
  
  get '/' do
    locations = Location.all
    json locations
  end

  # @api GET /{id}
  # @summary Get a specific location
  # @description Returns a specific location by ID
  # @parameter id [Integer] The ID of the location
  # @response 200 [Location] The requested location
  # @response 404 {error: String} Location not found
  get '/:id' do
    location = Location.find_by(id: params[:id].to_i)
    if location
      json location
    else
      status 404
      json error: 'Not found'
    end
  end

  # @api POST /
  # @summary Create a new location
  # @description Creates a new location with the provided data
  # @parameter request_body [LocationInput] The location data
  # @response 201 {id: Integer} The ID of the created location
  # @response 422 {errors: Array<String>} Validation errors
  post '/' do
    data = JSON.parse(request.body.read, symbolize_names: true)
    puts "Creating location with data: #{data.inspect}"
    location = Location.new(
      name: data[:name],
      address: data[:address]
    )
    puts "Location: #{location.inspect}"
    if location.save
      status 201
      json id: location.id
    else
      status 422
      json errors: location.errors.full_messages
    end
  end

  # @api PUT /{id}
  # @summary Update a location
  # @description Updates an existing location with the provided data
  # @parameter id [Integer] The ID of the location to update
  # @parameter request_body [LocationInput] The updated location data
  # @response 200 {updated: Boolean} Update status
  # @response 404 {error: String} Location not found
  # @response 422 {errors: Array<String>} Validation errors
  put '/:id' do
    data = JSON.parse(request.body.read, symbolize_names: true)
    location = Location.find_by(id: params[:id].to_i)
    
    if location
      updates = {}
      updates[:name] = data[:name] if data[:name]
      updates[:address] = data[:address] if data[:address]
      
      if location.update(updates)
        json updated: true
      else
        status 422
        json errors: location.errors.full_messages
      end
    else
      status 404
      json error: 'Not found'
    end
  end

  # @api DELETE /{id}
  # @summary Delete a location
  # @description Deletes a location by ID
  # @parameter id [Integer] The ID of the location to delete
  # @response 200 {deleted: Boolean} Deletion status
  # @response 404 {error: String} Location not found
  delete '/:id' do
    location = Location.find_by(id: params[:id].to_i)
    
    if location
      location.destroy
      json deleted: true
    else
      status 404
      json error: 'Not found'
    end
  end

  error Sinatra::NotFound do
    content_type 'text/plain'
    [404, 'Not Found']
  end
end

# AWS Lambda handler
def handler(event:, context:)
  # Check if the body is base64 encoded. If it is, try to decode it
  body = if event['isBase64Encoded']
    Base64.decode64 event['body']
  else
    event['body']
  end || ''

  # Rack expects the querystring in plain text, not a hash
  headers = event.fetch 'headers', {}

  # Environment required by Rack (http://www.rubydoc.info/github/rack/rack/file/SPEC)
  env = {
    'REQUEST_METHOD' => event.fetch('httpMethod'),
    'SCRIPT_NAME' => '',
    'PATH_INFO' => event.fetch('path', ''),
    'QUERY_STRING' => (event['queryStringParameters'] || {}).map { |k,v| "#{k}=#{v}" }.join('&'),
    'SERVER_NAME' => headers.fetch('Host', 'localhost'),
    'SERVER_PORT' => headers.fetch('X-Forwarded-Port', 443).to_s,

    #'rack.version' => Rack::VERSION,
    'rack.url_scheme' => headers.fetch('CloudFront-Forwarded-Proto') { headers.fetch('X-Forwarded-Proto', 'https') },
    'rack.input' => StringIO.new(body),
    'rack.errors' => $stderr,
  }

  # Pass request headers to Rack if they are available
  headers.each_pair do |key, value|
    # 'CloudFront-Forwarded-Proto' => 'CLOUDFRONT_FORWARDED_PROTO'
    # Content-Type and Content-Length are handled specially per the Rack SPEC linked above.
    name = key.upcase.gsub '-', '_'
    header = case name
      when 'CONTENT_TYPE', 'CONTENT_LENGTH'
        name
      else
        "HTTP_#{name}"
    end
    env[header] = value.to_s
  end

  begin
    # Response from Rack must have status, headers and body
    status, headers, body = LocationsApp.call(env)
  
    # body is an array. We combine all the items to a single string
    body_content = ""
    body.each do |item|
      body_content += item.to_s
    end

    # We return the structure required by AWS API Gateway since we integrate with it
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    response = {
      'statusCode' => status,
      'headers' => headers,
      'body' => body_content
    }
    if event['requestContext'].has_key?('elb')
      # Required if we use Application Load Balancer instead of API Gateway
      response['isBase64Encoded'] = false
    end
  rescue Exception => exception
    # If there is _any_ exception, we return a 500 error with an error message
    response = {
      'statusCode' => 500,
      'body' => exception.message
    }
  end

  # By default, the response serializer will call #to_json for us
  response
end
