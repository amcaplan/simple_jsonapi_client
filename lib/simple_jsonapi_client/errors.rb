module SimpleJSONAPIClient
  class Base
    class Error < StandardError
    end

    require 'simple_jsonapi_client/errors/api_error'
  end
end
