# This Ruby code block includes the necessary dependencies and defines a class called Home.

# Require the 'sinatra' library for web application functionality.
require 'sinatra'

# Require 'json' for JSON parsing and serialization.
require 'json'

# Require 'pry' for debugging and interactive console.
require 'pry'

# Require 'active_model' for adding validation capabilities to the Home class.
require 'active_model'

# Global variable $home is defined to store data related to homes.
$home = {}

# Define a class called Home.
class Home
  include ActiveModel::Validations

  # Define attribute accessors for the Home class.
  attr_accessor :town, :name, :description, :domain_name, :content_version

  # Validate the presence of the 'town' attribute.
  validates :town, presence: true, inclusion: { in: [
    "melomaniac-mansion",
    'cooker-cove',
    "the-nomad-pad",
    "gamers-grotto",
    "video-valley",
    "Ripping-Rap-Ridge"  # make sure to choose a town that is already in the list
  ]}

  # Validate the presence of the 'name' attribute.
  validates :name, presence: true

  # Validate the presence of the 'description' attribute.
  validates :description, presence: true

  # Validate the 'domain_name' attribute using a regular expression, ensuring it ends with '.cloudfront.net'.
  # If the format validation fails, a custom error message will be displayed.
  validates :domain_name, 
    format: { with: /\.cloudfront\.net\z/, message: "domain must be from .cloudfront.net" }
    # uniqueness: true,

  # Validate the 'content_version' attribute, ensuring it is an integer.
  validates :content_version, numericality: { only_integer: true }
end

# This Ruby class, TerraTownsMockServer, is a Sinatra application that serves as a mock server for handling TerraTowns-related requests.
class TerraTownsMockServer < Sinatra::Base

  # A helper method for responding with a JSON error message.
  # It takes 'code' as the HTTP status code and 'message' as the error message.
  # It halts the execution of the request, responding with the appropriate status code, content type, and JSON error
  def error code, message
    halt code, {'Content-Type' => 'application/json'}, {err: message}.to_json
  end

  # A helper method for responding with a JSON response.
  # It takes 'json' as the JSON data to be included in the response.
  # It halts the execution of the request, responding with a JSON response and the appropriate content type.
  def error_json json
    halt code, {'Content-Type' => 'application/json'}, json
  end

  # A helper method for ensuring that the incoming request has the correct Content-Type and Accept headers.
  # It checks if the 'CONTENT_TYPE' header is set to 'application/json' and the 'HTTP_ACCEPT' header is set to 'application/json'.
  # If any of these headers are not as expected, it responds with an error message and the appropriate HTTP status code.
  def ensure_correct_headings
    unless request.env["CONTENT_TYPE"] == "application/json"
      error 415, "expected Content_type header to be application/json"
    end

    unless request.env["HTTP_ACCEPT"] == "application/json"
      error 406, "expected Accept header to be application/json"
    end
  end

  # These two Ruby methods, 'x_access_code' and 'x_user_uuid', are simple utility methods that return hard-coded values.
  # They are typically used to provide default values for specific access codes and user UUIDs in an application.

  # Method 'x_access_code' returns a predefined access code as a string.
  def x_access_code
    '9b49b3fb-b8e9-483c-b703-97ba88eef8e0'
  end

  # Method 'x_user_uuid' returns a predefined user UUID as a string.
  def x_user_uuid
    'e328f4ab-b99f-421c-84c9-4ccea042c7d1'
  end

  # This Ruby method, 'find_user_by_bearer_token', is responsible for authenticating a user based on a bearer token and user UUID.
  # It is used in a web application to ensure that incoming requests are authorized and that the provided credentials are valid.
  # https://swagger.io/docs/specification/authentication/bearer-authentication

  def find_user_by_bearer_token
    # Retrieve the 'Authorization' header from the request's environment.
    auth_header = request.env["HTTP_AUTHORIZATION"]

    # Check if the 'Authorization' header is missing or doesn't start with "Bearer ".
    # If either condition is true, respond with a 401 Unauthorized error.
    if auth_header.nil? || !auth_header.start_with?("Bearer ")
      error 401, "a1000 Failed to authenticate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end

    # Extract the bearer token from the 'Authorization' header.
    code = auth_header.split("Bearer ")[1]

    # Check if the extracted bearer token matches the predefined access code.
    # If not, respond with a 401 Unauthorized error.
    if code != x_access_code
      error 401, "a1001 Failed to authenticate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end

    # Check if the 'user_uuid' parameter is missing in the request.
    # If it is missing, respond with a 401 Unauthorized error.
    if params['user_uuid'].nil?
      error 401, "a1002 Failed to authenticate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end

    # Ensure that both the bearer token and the 'user_uuid' parameter match the predefined values.
    # If either condition is not met, respond with a 401 Unauthorized error.
    unless code == x_access_code && params['user_uuid'] == x_user_uuid
      error 401, "a1003 Failed to authenticate, bearer token invalid and/or teacherseat_user_uuid invalid"
    end
  end


  # CREATE
  # This Sinatra route handles a POST request to create a new home for a specific user identified by 'user_uuid'.
  # It performs several checks and operations before processing the request.

  post '/api/u/:user_uuid/homes' do
    # Ensure that the incoming request has the correct Content-Type and Accept headers.
    ensure_correct_headings

    # Authenticate the user by verifying the bearer token and 'user_uuid'.
    find_user_by_bearer_token

    # Log the request information for debugging purposes.
    puts "# create - POST /api/homes"

    begin
      # Attempt to parse the JSON payload from the request body.
      payload = JSON.parse(request.body.read)
    rescue JSON::ParserError
      # If the JSON parsing fails, respond with a 422 Unprocessable Entity error.
      halt 422, "Malformed JSON"
    end

    # The code block above is responsible for ensuring that the request is properly formatted,
    # authorized, and that the JSON payload is successfully parsed. If any of these conditions
    # are not met, appropriate responses are provided, and the request is halted as necessary.

    # Validate payload data
    # This section of Ruby code extracts data from the 'payload' JSON object received in the request.
    # It assigns the extracted values to respective variables and logs them for debugging purposes.

    # Extract the 'name' field from the JSON payload.
    name = payload["name"]

    # Extract the 'description' field from the JSON payload.
    description = payload["description"]

    # Extract the 'domain_name' field from the JSON payload.
    domain_name = payload["domain_name"]

    # Extract the 'content_version' field from the JSON payload.
    content_version = payload["content_version"]

    # Extract the 'town' field from the JSON payload.
    town = payload["town"]

    # Log the extracted values for debugging and monitoring purposes.
    puts "name #{name}"
    puts "description #{description}"
    puts "domain_name #{domain_name}"
    puts "content_version #{content_version}"
    puts "town #{town}"

    # Create a new instance of the 'Home' class.
    home = Home.new

    # Set the attributes of the 'home' instance with the values extracted from the request payload.

    # Assign the 'town' value from the payload to the 'town' attribute of the 'home' instance.
    home.town = town

    # Assign the 'name' value from the payload to the 'name' attribute of the 'home' instance.
    home.name = name

    # Assign the 'description' value from the payload to the 'description' attribute of the 'home' instance.
    home.description = description

    # Assign the 'domain_name' value from the payload to the 'domain_name' attribute of the 'home' instance.
    home.domain_name = domain_name

    # Assign the 'content_version' value from the payload to the 'content_version' attribute of the 'home' instance.
    home.content_version = content_version
    
    # Check if the 'home' object is valid according to the defined validations.
    unless home.valid?
      # If the object is not valid, respond with a 422 Unprocessable Entity error,
      # including the validation error messages in JSON format.
      error 422, home.errors.messages.to_json
    end

    # In this Ruby code block, a unique UUID is generated using SecureRandom.uuid.
    # The UUID is then used to create a new 'home' object, and its attributes are populated with data extracted from the JSON payload.
    # Finally, a response JSON object is constructed and returned.

    # Generate a unique UUID using SecureRandom.uuid.
    uuid = SecureRandom.uuid

    # Log the generated UUID for reference or debugging.
    puts "uuid #{uuid}"

    # Create a new '$home' object with attributes based on the extracted data and the generated UUID.
    $home = {
      uuid: uuid,
      name: name,
      town: town,
      description: description,
      domain_name: domain_name,
      content_version: content_version
    }

    # Construct a JSON response object containing the generated UUID and return it as the response.
    return { uuid: uuid }.to_json
  end

  # READ
  # This Sinatra route handles a GET request to retrieve information about a home with a specific UUID.
  # It performs several checks and operations before responding to the request.

  get '/api/u/:user_uuid/homes/:uuid' do
    # Ensure that the incoming request has the correct Content-Type and Accept headers.
    ensure_correct_headings

    # Authenticate the user by verifying the bearer token and 'user_uuid'.
    find_user_by_bearer_token

    # Log the request information for debugging purposes.
    puts "# read - GET /api/homes/:uuid"

    # Set the Content-Type of the response to JSON.
    content_type :json

    # Check if the 'uuid' parameter in the request matches the UUID of the stored home.
    if params[:uuid] == $home[:uuid]
      # If the UUIDs match, return the home data as a JSON response.
      return $home.to_json
    else
      # If the UUIDs do not match, respond with a 404 Not Found error.
      error 404, "failed to find home with provided uuid and bearer token"
    end
  end


  # UPDATE
  # This Sinatra route handles a PUT request to update information about a home with a specific UUID.
  # It performs several checks and operations before responding to the request.

  put '/api/u/:user_uuid/homes/:uuid' do
    # Ensure that the incoming request has the correct Content-Type and Accept headers.
    ensure_correct_headings

    # Authenticate the user by verifying the bearer token and 'user_uuid'.
    find_user_by_bearer_token

    # Log the request information for debugging purposes.
    puts "# update - PUT /api/homes/:uuid"

    begin
      # Attempt to parse JSON payload from the request body.
      payload = JSON.parse(request.body.read)
    rescue JSON::ParserError
      # If the JSON parsing fails, respond with a 422 Unprocessable Entity error.
      halt 422, "Malformed JSON"
    end

    # Extract data from the payload for validation and updates.
    name = payload["name"]
    description = payload["description"]
    content_version = payload["content_version"]

    # Check if the 'uuid' parameter in the request matches the UUID of the stored home.
    unless params[:uuid] == $home[:uuid]
      # If the UUIDs do not match, respond with a 404 Not Found error.
      error 404, "failed to find home with provided uuid and bearer token"
    end

    # Create a new 'Home' object and set its attributes for validation.
    home = Home.new
    home.town = $home[:town]
    home.name = name
    home.description = description
    home.domain_name = $home[:domain_name]
    home.content_version = content_version

    # Check if the 'home' object is valid according to the defined validations.
    unless home.valid?
      # If the object is not valid, respond with a 422 Unprocessable Entity error,
      # including the validation error messages in JSON format.
      error 422, home.errors.messages.to_json
    end

    # Return a JSON response indicating the updated 'uuid'.
    return { uuid: params[:uuid] }.to_json
  end


  # DELETE
  # This Sinatra route handles a DELETE request to delete a home with a specific UUID.
  # It performs several checks and operations before responding to the request.

  delete '/api/u/:user_uuid/homes/:uuid' do
    # Ensure that the incoming request has the correct Content-Type and Accept headers.
    ensure_correct_headings

    # Authenticate the user by verifying the bearer token and 'user_uuid'.
    find_user_by_bearer_token

    # Log the request information for debugging purposes.
    puts "# delete - DELETE /api/homes/:uuid"

    # Set the Content-Type of the response to JSON.
    content_type :json

    # Check if the 'uuid' parameter in the request matches the UUID of the stored home.
    if params[:uuid] != $home[:uuid]
      # If the UUIDs do not match, respond with a 404 Not Found error.
      error 404, "failed to find home with provided uuid and bearer token"
    end

    # Clear the '$home' object to simulate the deletion of the home.
    uuid = $home[:uuid]
    $home = {}
    { uuid: uuid }.to_json

    # Return a JSON response indicating the successful deletion of the house.
    # { message: "House deleted successfully" }.to_json
  end
end

# This command runs the server
TerraTownsMockServer.run!