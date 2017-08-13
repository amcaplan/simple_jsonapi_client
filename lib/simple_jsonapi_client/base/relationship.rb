module SimpleJSONAPIClient
  class Base
    class Relationship
      def initialize(model_class, url_opts = {})
        @model_class = model_class
        @url_opts = url_opts
      end

      def call(*args)
        raise NotImplementedError
      end

      private
      attr_reader :url_opts

      def model_class
        @evaluated_model_class ||=
          case @model_class
          when String
            Kernel::const_get(@model_class)
          else
            @model_class
          end
      end

      def link_from(info)
        info['links'].to_h.values_at('related', 'self').compact.first
      end
    end
  end
end

require 'simple_jsonapi_client/base/has_many_relationship'
require 'simple_jsonapi_client/base/has_one_relationship'
