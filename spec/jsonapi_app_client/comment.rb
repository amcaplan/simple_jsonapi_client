class JSONAPIAppClient
  class Comment < SimpleJSONAPIClient::Base
    COLLECTION_URL = '/comments'
    INDIVIDUAL_URL = '/comments/%{id}'
    TYPE = 'comments'

    attributes :text

    has_one :post, class_name: 'JSONAPIAppClient::Post'
    has_one :author, class_name: 'JSONAPIAppClient::Author'
  end
end
