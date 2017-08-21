require 'simple_jsonapi_client/relationships/link_relationship_proxy'

module SimpleJSONAPIClient
  module Relationships
    class SingularLinkRelationship < LinkRelationshipProxy
      private

      def fetch_internal_object
        @klass.fetch(connection: @connection, url: @url)
      end
    end
  end
end
