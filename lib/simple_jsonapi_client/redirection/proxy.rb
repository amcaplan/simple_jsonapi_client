require 'delegate'

module SimpleJSONAPIClient
  module Redirection
    class Proxy
      extend Forwardable

      def_delegator :internal_object, :nil?

      def inspect
        if @internal_object
          @internal_object.inspect
        else
          pseudo_inspect
        end
      end

      def method_missing(meth, *args, &block)
        self.class.def_delegator :internal_object, meth
        internal_object.__send__(meth, *args, &block)
      end

      def respond_to_missing?(*args)
        internal_object.__send__(:respond_to?, *args)
      end

      def as_json
        if internal_object.respond_to?(:as_json)
          internal_object.as_json
        elsif internal_object.is_a?(Array)
          internal_object.map(&:as_json)
        elsif nil?
          nil
        else
          raise "Cannot convert #{inspect} to JSON!"
        end
      end

      private

      def internal_object
        @internal_object ||= fetch_internal_object
      end

      def pseudo_inspect
        raise NotImplementedError
      end

      def fetch_internal_object
        raise NotImplementedError
      end
    end
  end
end
