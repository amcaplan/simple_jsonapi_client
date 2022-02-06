class AuthorResource < JSONAPI::Resource
  attributes :name
  filter :name

  has_many :posts
  has_many :comments

  def self.creatable_fields(_context = nil)
    super + [:id]
  end
end
