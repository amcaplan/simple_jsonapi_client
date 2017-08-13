class Author < ApplicationRecord
  has_many :posts
  has_many :comments

  validates :name, length: { maximum: 50 }
end
