class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :post

  validates :post, :presence => true
  validates :user, :presence => true
end
