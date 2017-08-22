require 'faraday'
require 'faraday_middleware'

Dir.glob('./**/jsonapi_app_client/**/*.rb').each do |file|
  require file
end

class JSONAPIAppClient
  url = ENV.fetch("API_URL")
  port = ENV.fetch("API_PORT") { 3000 }
  API_URL = "http://#{url}:#{port}"

  def connection
    default_headers = {
      'Accept' => 'application/vnd.api+json',
      'Content-Type' => 'application/vnd.api+json'
    }

    @connection ||= Faraday.new(url: API_URL, headers: default_headers) do |connection|
      connection.request :json
      connection.response :json, :content_type => /\bjson$/
      connection.adapter :net_http
    end
  end
end
