require 'simple_jsonapi_client/redirection/proxy'

module SimpleJSONAPIClient
  module Relationships
    class LinkRelationshipProxy < ::SimpleJSONAPIClient::Redirection::Proxy
      def initialize(klass, connection, url)
        @klass = klass
        @connection = connection
        @url = url
      end

      private

      def pseudo_inspect
        "#<#{self.class.name} model_class=#{@klass} url=#{@url}>"
      end
    end
  end
end
