class JSONAPIAppClient
  class Author < SimpleJSONAPIClient::Base
    COLLECTION_URL = '/authors'
    INDIVIDUAL_URL = '/authors/%{id}'
    TYPE = 'authors'

    attributes :name

    has_many :posts, class_name: 'JSONAPIAppClient::Post'
    has_many :comments, class_name: 'JSONAPIAppClient::Comment'
  end
end
