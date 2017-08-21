require 'simple_jsonapi_client/relationships/singular_data_relationship'
require 'simple_jsonapi_client/relationships/singular_link_relationship'

module SimpleJSONAPIClient
  module Relationships
    class HasOneRelationship < Relationship
      def call(info, included, connection)
        if (record = info['data'])
          SingularDataRelationship.new(model_class, record, included, connection)
        elsif (link = link_from(info))
          SingularLinkRelationship.new(model_class, connection, link)
        end
      end
    end
  end
end
