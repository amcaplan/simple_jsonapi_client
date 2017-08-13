class AuthorResource < JSONAPI::Resource
  attributes :name

  has_many :posts
  has_many :comments
end
