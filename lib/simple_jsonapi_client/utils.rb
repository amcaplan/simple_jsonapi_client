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
