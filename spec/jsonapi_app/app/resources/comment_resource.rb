class CommentResource < JSONAPI::Resource
  attributes :text

  has_one :post
  has_one :author
end
