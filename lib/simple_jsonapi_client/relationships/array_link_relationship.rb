require 'simple_jsonapi_client/relationships/link_relationship_proxy'

module SimpleJSONAPIClient
  module Relationships
    class ArrayLinkRelationship < LinkRelationshipProxy
      def_delegators :internal_object, *(Array.instance_methods(false) - instance_methods)

      private

      def fetch_internal_object
        @klass.fetch_all(connection: @connection, url: @url)
      end
    end
  end
end
