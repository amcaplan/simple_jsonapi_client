require 'delegate'

module SimpleJSONAPIClient
  module Errors
    class APIError < ::SimpleJSONAPIClient::Error
      extend Forwardable

      KNOWN_ERRORS = {
        400 => 'BadRequestError',
        404 => 'NotFoundError',
        422 => 'UnprocessableEntityError'
      }
      KNOWN_ERRORS.default = 'APIError'

      def self.generate(response)
        error = KNOWN_ERRORS[response.status]
        SimpleJSONAPIClient::Errors.const_get(error).new(response)
      end

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

    BadRequestError          = Class.new(APIError)
    NotFoundError            = Class.new(APIError)
    UnprocessableEntityError = Class.new(APIError)
  end
end
