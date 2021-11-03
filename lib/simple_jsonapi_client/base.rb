require 'simple_jsonapi_client/utils'
require 'simple_jsonapi_client/error'
require 'simple_jsonapi_client/relationships/relationship'
require 'simple_jsonapi_client/redirection/fetch_all'

module SimpleJSONAPIClient
  class Base
    class << self
      def relationships
        @relationships ||= {}
      end

      def _attributes
        @_attributes ||= {}
      end

      def attributes(*attrs)
        attrs.each do |attr|
          define_method(attr) { attributes[attr] }
          define_method("#{attr}=") { |x| attributes[attr] = x }
          _attributes[attr] = true
        end
      end

      def meta(*attrs)
        attrs.each do |attr|
          define_method(attr) { meta[attr] }
          define_method("#{attr}=") { |x| meta[attr] = x }
        end
      end

      def has_many(relationship_name, opts)
        model_class = opts.fetch(:class) { opts.fetch(:class_name) }
        define_relationship_methods!(relationship_name)
        relationships[relationship_name.to_sym] =
          Relationships::HasManyRelationship.new(model_class)
      end

      def has_one(relationship_name, opts)
        define_relationship_methods!(relationship_name)
        model_class = opts.fetch(:class) { opts.fetch(:class_name) }
        relationships[relationship_name.to_sym] =
          Relationships::HasOneRelationship.new(model_class)
      end

      def fetch(opts)
        operation(:fetch_request, :singular, opts)
      end

      def fetch_all(opts)
        Redirection::FetchAll.new(opts) do |request_opts|
          operation(:fetch_all_request, :plural, request_opts)
        end
      end

      def create(opts)
        operation(:create_request, :singular, opts)
      end

      def update(opts)
        operation(:update_request, :singular, opts)
      end

      def delete(opts)
        operation(:delete_request, :empty, opts)
        true
      end

      def model_from(record, included, connection, context = nil)
        return unless record
        new(
          meta: record['meta'],
          id: record['id'],
          attributes: record.fetch('attributes', {}),
          relationships: record.fetch('relationships', {}),
          context: context,
          included: included,
          connection: connection
        )
      end

      def interpreted_included(records, included)
        {}.tap do |included_hash|
          include_records(included_hash, records)
          include_records(included_hash, included)
        end
      end

      def include_records(included_hash, records)
        records.to_a.each do |record|
          included_hash[{ 'id' => record['id'], 'type' => record['type'] }] = record
        end
      end

      def template(id: nil, attributes:, relationships: {})
        data = {
          type: self::TYPE,
          attributes: attributes,
          relationships: interpreted_relationships(relationships)
        }
        data[:id] = id if id
        { data: data }
      end

      private

      def define_relationship_methods!(relationship_name)
        define_method(relationship_name) { relationships[relationship_name] }
        define_method("#{relationship_name}=") { |x| relationships[relationship_name] = x }
      end

      def operation(request_method, response_type, opts)
        response = send(request_method, opts)
        handling_error(response) do
          send(:"interpret_#{response_type}_response", response, opts[:connection])
        end
      end

      def create_request(connection:,
                         id: nil,
                         url_opts: {},
                         url: self::COLLECTION_URL % url_opts,
                         attributes: {},
                         relationships: {},
                         **attrs)
        attributes, relationships = extract_attrs(attrs, attributes, relationships)
        body = template(id: id, attributes: attributes, relationships: relationships)
        connection.post(url, body)
      end

      def update_request(connection:,
                         id:,
                         url_opts: {},
                         attributes: {},
                         relationships: {},
                         **attrs)
        attributes, relationships = extract_attrs(attrs, attributes, relationships)
        connection.patch(self::INDIVIDUAL_URL % url_opts) do |request|
          request.body = template(
            id: id,
            attributes: attributes,
            relationships: relationships
          )
        end
      end

      def delete_request(connection:, url_opts: {})
        connection.delete(self::INDIVIDUAL_URL % url_opts)
      end

      def fetch_request(connection:,
                        url_opts: {},
                        filter_opts: {},
                        url: self::INDIVIDUAL_URL % url_opts,
                        includes: [])
        params = {}
        params[:include] = includes.join(',') unless includes.empty?
        params[:filter] = filter_opts unless filter_opts.empty?
        connection.get(url, params)
      end

      def fetch_all_request(connection:,
                            url_opts: {},
                            url: self::COLLECTION_URL % url_opts,
                            filter_opts: {},
                            page_opts: {},
                            includes: [])
        params = {}
        params[:include] = includes.join(',') unless includes.empty?
        params[:filter] = filter_opts unless filter_opts.empty?
        params[:page] = page_opts unless page_opts.empty?
        connection.get(url, params)
      end

      def extract_attrs(attrs, attributes, relationships)
        attrs.each do |attr, value|
          if _attributes.key?(attr)
            attributes[attr] = value
          elsif self.relationships.key?(attr)
            relationships[attr] = value
          else
            raise ArgumentError, %{Invalid attribute "#{attr}"}
          end
        end
        [attributes, relationships]
      end

      def interpret_singular_response(response, connection)
        body = response.body
        record = body['data']
        records = [record].compact
        included = interpreted_included(records, body['included'])
        model_from(record, included, connection, response)
      end

      def interpret_plural_response(response, connection)
        body = response.body
        records = body['data']
        included = interpreted_included(records, body['included'])
        {
          'links' => body['links'],
          'data' => records.map { |record|
            model_from(record, included, connection, response)
          }
        }
      end

      def interpret_empty_response(response, connection)
      end

      if {}.respond_to?(:transform_values)
        def interpreted_relationships(relationships)
          relationships.transform_values { |value|
            if (relationship = relationship_from(value))
              { data: relationship }
            end
          }
        end
      else
        def interpreted_relationships(relationships)
          Utils.transform_values(relationships) { |value|
            if (relationship = relationship_from(value))
              { data: relationship }
            end
          }
        end
      end

      def relationship_from(value)
        if value.respond_to?(:to_relationship)
          value.to_relationship
        elsif value.respond_to?(:map)
          value.map(&:to_relationship)
        elsif !value.nil?
          raise ArgumentError, "#{value} cannot be converted to relationship!"
        end
      end

      def handling_error(response)
        if response.success?
          yield
        else
          raise ::SimpleJSONAPIClient::Errors::APIError.generate(response)
        end
      end
    end

    attr_reader :id, :context

    def initialize(meta: nil, id:, attributes: nil, relationships: nil, included: {}, connection:, context: nil)
      @meta = Utils.symbolize_keys(meta) if meta
      @id = id
      @included = included
      @connection = connection
      @context = context
      @attributes = Utils.symbolize_keys(attributes) if attributes
      @input_relationships = relationships
    end

    def to_relationship
      { type: self.class::TYPE, id: id }
    end

    def same_record_as?(other)
      to_relationship == other.to_relationship
    end

    def attributes
      @attributes ||= loaded_record.attributes
    end

    def meta
      @meta ||= loaded_record.meta
    end

    def relationships
      @relationships ||=
        begin
          if input_relationships
            relationships_to_models(Utils.symbolize_keys(input_relationships))
          else
            loaded_record.relationships
          end
        end
    end

    def update(**attrs)
       self.class.update(
         connection: connection,
         id: id,
         url_opts: { id: id },
         **attrs
       )
    end

    def delete
      self.class.delete(
        connection: connection,
        url_opts: { id: id }
      )
    end

    def as_json
      self.class.template(
        id: id,
        attributes: attributes,
        relationships: relationships
      )
    end

    def to_json(*args)
      as_json.to_json(*args)
    end

    def inspect
      parsed_attributes = attributes.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
      parsed_attributes = " #{parsed_attributes}" unless parsed_attributes.empty?
      parsed_relationships = relationships.map { |key, value| "#{key}=#{value.inspect}" }.join(' ')
      parsed_relationships = " #{parsed_relationships}" unless parsed_relationships.empty?
      "#<#{self.class.name} id=#{id}#{parsed_attributes}#{parsed_relationships}>"
    end

    private
    attr_reader :input_relationships, :included, :connection

    def relationships_to_models(relationships)
      relationships.each_with_object({}) do |(relationship, info), memo|
        next unless implementation = self.class.relationships[relationship]
        memo[relationship] = implementation.call(info, included, connection)
      end
    end

    def loaded_record
      @loaded_record ||= self.class.fetch(connection: connection, url_opts: { id: id })
    end
  end
end
