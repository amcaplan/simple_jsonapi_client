require 'simple_jsonapi_client/base/proxy'

module SimpleJSONAPIClient
  class Base
    class DataRelationshipProxy < ::SimpleJSONAPIClient::Base::Proxy
      def initialize(klass, records, included, connection)
        @klass = klass
        @record_or_records = records
        @included = included
        @connection = connection
      end

      private

      def instantiated_relationship_record(record)
        @klass.model_from(
          initialization_data(record),
          @included,
          @connection
        )
      end

      def initialization_data(record)
        @included.fetch(record) do
          { 'attributes' => nil, 'relationships' => nil }.merge!(record)
        end
      end
    end
  end
end
