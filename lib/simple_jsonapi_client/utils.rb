module SimpleJSONAPIClient
  module Utils
    class <<  self
      # Implementation adapted from ActiveSupport
      # Copyright (c) 2005-2019 David Heinemeier Hansson
      # https://github.com/rails/rails/blob/b9ca94caea2ca6a6cc09abaffaad67b447134079/activesupport/lib/active_support/core_ext/hash/keys.rb
      def symbolize_keys(hash)
        result = {}
        hash.each_key do |key|
          result[(key.to_sym rescue key)] = hash[key]
        end
        result
      end

      def hash_dig(hash, *keys)
        if hash.respond_to?(:dig)
          hash.dig(*keys)
        else
          dig(hash, keys)
        end
      end

      private

      # Implementation adapted from the hash_dig gem, Copyright (c) 2015 Colin Kelley, MIT License
      # https://github.com/Invoca/ruby_dig/blob/19fa8c1d2cc7706d015a3004f028169a2ff83391/lib/ruby_dig.rb
      def dig(hash, key, *rest)
        value = hash[key]
        if value.nil? || rest.empty?
          value
        elsif value.is_a?(Hash) || value.is_a?(Array)
          dig(value, *rest)
        else
          fail TypeError, "#{value.class} does not work with #dig" # should not happen with our use of #dig
        end
      end

      def transform_values(hash)
        result = {}
        hash.each do |key, value|
          result[key] = yield(value)
        end
        result
      end
    end
  end
end
