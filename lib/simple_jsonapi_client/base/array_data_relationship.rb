require 'simple_jsonapi_client/base/data_relationship_proxy'

module SimpleJSONAPIClient
  class Base
    class ArrayDataRelationship < ::SimpleJSONAPIClient::Base::DataRelationshipProxy
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
