class Post < ApplicationRecord
  belongs_to :author, optional: true
  has_many :comments, dependent: :destroy
end
