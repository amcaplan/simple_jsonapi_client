class AuthorResource < JSONAPI::Resource
  attributes :name
  filter :name

  has_many :posts
  has_many :comments
end
