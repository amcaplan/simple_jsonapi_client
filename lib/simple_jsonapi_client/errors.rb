require 'delegate'

module SimpleJSONAPIClient
  class Base
    class Error < StandardError
    end

    class ApiError < Error
      extend Forwardable

      attr_reader :response
      def_delegators :response, :status, :body

      def initialize(response)
        @response = response
        super(full_message)
      end

      def errors
        Array(body['errors'])
      end

      def message
        if !codes.empty?
          codes_message
        elsif !details.empty?
          details_message
        else
          default_message
        end
      end

      def full_message
        "The API returned a #{status} error status and this content:\n" +
          pretty_printed_response.each_line.map { |line| "  #{line}" }.join
      end

      def codes
        @codes ||= errors.map { |error| error['code'] }.compact
      end

      def details
        @details ||= errors.map { |error| error['detail'] }.compact
      end

      private

      def pretty_printed_response
        JSON.pretty_generate(body)
      end

      def codes_message
        codes_word = codes.size == 1 ? 'code' : 'codes'
        "The API returned a #{status} error status with the following error #{codes_word}: #{
        codes.map(&:inspect).join(', ')
        }"
      end

      def details_message
        details_word = details.size == 1 ? 'detail' : 'details'
        "The API returned a #{status} error status with the following error #{details_word}: #{
        details.map(&:inspect).join(', ')
        }"
      end

      def default_message
        "The API responded with a #{status} error status."
      end
    end
  end
end
