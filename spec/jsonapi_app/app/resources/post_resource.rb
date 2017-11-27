class PostResource < JSONAPI::Resource
  attributes :title, :text

  has_one :author
  has_many :comments

  def meta(options)
    {
      copyright: "Copyright #{_model.updated_at.year}"
    }
  end
end
