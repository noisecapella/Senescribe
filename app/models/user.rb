class User < ActiveRecord::Base
  attr_accessible :identity_url, :description, :email
  validates_uniqueness_of :identity_url
  validates_presence_of :identity_url, :description, :email

  has_one :blog
  has_and_belongs_to_many :users, :foreign_key => :user_to_id, :uniq => true
  has_many :posts
  has_many :comments

  

end
