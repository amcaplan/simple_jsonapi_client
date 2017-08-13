require 'simple_jsonapi_client/base/data_relationship_proxy'

module SimpleJSONAPIClient
  class Base
    class SingularDataRelationship < ::SimpleJSONAPIClient::Base::DataRelationshipProxy
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
