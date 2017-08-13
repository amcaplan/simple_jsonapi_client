class PostResource < JSONAPI::Resource
  attributes :title, :text

  has_one :author
  has_many :comments
end
