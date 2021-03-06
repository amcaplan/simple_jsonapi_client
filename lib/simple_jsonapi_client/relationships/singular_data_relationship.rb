require 'simple_jsonapi_client/relationships/data_relationship_proxy'

module SimpleJSONAPIClient
  module Relationships
    class SingularDataRelationship < DataRelationshipProxy
      private

      def pseudo_inspect
        "#<#{self.class.name} model_class=#{@klass} id=#{@record_or_records['id']}}>"
      end

      def fetch_internal_object
        instantiated_relationship_record(@record_or_records)
      end
    end
  end
end
