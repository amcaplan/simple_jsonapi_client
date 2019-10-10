require 'simple_jsonapi_client/redirection/proxy'

module SimpleJSONAPIClient
  module Redirection
    class FetchAll < ::SimpleJSONAPIClient::Redirection::Proxy
      def_delegators :internal_enumerator, *(Enumerator.instance_methods(false) - instance_methods)
      def_delegators :internal_enumerator, *(Enumerable.instance_methods(false) - instance_methods)
      def_delegators :internal_object, :size, *(Array.instance_methods(false) - instance_methods)

      def initialize(base_opts, &operation)
        @base_opts = base_opts
        @operation = operation
      end

      private
      attr_reader :base_opts, :operation

      def pseudo_inspect
        internal_enumerator.inspect
      end

      def fetch_internal_object
        internal_enumerator.to_a
      end

      def internal_enumerator
        @internal_enumerator ||= Enumerator.new do |yielder|
          loop do
            current_response = operation.call(current_opts)
            current_response['data'].each do |record|
              yielder << record
            end
            break unless (next_link = Utils.hash_dig(current_response, 'links', 'next'))
            current_opts.merge!(url_opts: {}, url: next_link)
            current_opts.delete(:page_opts)
          end
        end
      end

      def current_opts
        @current_opts ||= base_opts.dup
      end
    end
  end
end
