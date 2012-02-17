class User < ActiveRecord::Base
  attr_accessible :identity_url, :description, :email

  validates :identity_url, :presence => true, :uniqueness => true
  validates :description, :presence => true
  validates :email, :presence => true

  has_one :blog
  has_and_belongs_to_many :users, :foreign_key => :user_to_id, :uniq => true
  has_many :posts
  has_many :comments

  

end
