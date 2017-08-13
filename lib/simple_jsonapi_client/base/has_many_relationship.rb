require 'simple_jsonapi_client/base/array_data_relationship'
require 'simple_jsonapi_client/base/array_link_relationship'

module SimpleJSONAPIClient
  class Base
    class HasManyRelationship < Relationship
      def call(info, included, connection)
        if (records = info['data'])
          ArrayDataRelationship.new(model_class, records, included, connection)
        elsif (link = link_from(info))
          ArrayLinkRelationship.new(model_class, connection, link)
        end
      end
    end
  end
end
