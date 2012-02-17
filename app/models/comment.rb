class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates :post, :precense => true
  validates :user, :precense => true
end
