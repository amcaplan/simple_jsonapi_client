require 'faraday'
require 'faraday_middleware'

Dir.glob('./**/jsonapi_app_client/**/*.rb').each do |file|
  require file
end

class JSONAPIAppClient
  API_URL = 'http://jsonapi_app:3000'

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

  def fetch_authors
    Author.fetch_all(connection: connection)
  end

  def fetch_author(id)
    Author.fetch(
      connection: connection,
      url_opts: { id: id }
    )
  end

  def create_author(name:)
    Author.create(
      attributes: {name: name},
      connection: connection
    )
  end
end
