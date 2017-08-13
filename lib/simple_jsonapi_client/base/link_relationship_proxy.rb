require 'simple_jsonapi_client/base/proxy'

module SimpleJSONAPIClient
  class Base
    class LinkRelationshipProxy < ::SimpleJSONAPIClient::Base::Proxy
      def initialize(klass, connection, url)
        @klass = klass
        @connection = connection
        @url = url
      end

      private

      def pseudo_inspect
        "#<#{self.class.name} model_class=#{@klass} url=#{@url}>"
      end
    end
  end
end
