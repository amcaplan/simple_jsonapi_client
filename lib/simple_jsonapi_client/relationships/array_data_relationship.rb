require 'simple_jsonapi_client/relationships/data_relationship_proxy'

module SimpleJSONAPIClient
  module Relationships
    class ArrayDataRelationship < DataRelationshipProxy
      private

      def pseudo_inspect
        "#<#{self.class.name} model_class=#{@klass} ids=#{@record_or_records.map { |record| record['id'] }}>"
      end

      def fetch_internal_object
        @record_or_records.map { |record|
          instantiated_relationship_record(record)
        }
      end
    end
  end
end
