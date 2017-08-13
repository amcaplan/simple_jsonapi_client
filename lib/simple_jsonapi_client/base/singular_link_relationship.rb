require 'simple_jsonapi_client/base/link_relationship_proxy'

module SimpleJSONAPIClient
  class Base
    class SingularLinkRelationship < ::SimpleJSONAPIClient::Base::LinkRelationshipProxy
      private

      def fetch_internal_object
        @klass.fetch(connection: @connection, url: @url)
      end
    end
  end
end
