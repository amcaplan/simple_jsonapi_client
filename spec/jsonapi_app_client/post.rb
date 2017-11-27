class JSONAPIAppClient
  class Post < SimpleJSONAPIClient::Base
    COLLECTION_URL = '/posts'
    INDIVIDUAL_URL = '/posts/%{id}'
    TYPE = 'posts'

    attributes :title, :text
    meta :copyright

    has_one :author, class_name: 'JSONAPIAppClient::Author'
    has_many :comments, class_name: 'JSONAPIAppClient::Comment'
  end
end
