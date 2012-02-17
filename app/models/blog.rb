class Blog < ActiveRecord::Base
  validates :user_id, :uniqueness => true, :presence => true
  
  validates :posts_per_page, :presence => true, :inclusion => { :in => 1..100 }, :message => "Number of posts per page should be between 0 and 100"
  validates :comments_per_page, :presense => true, :inclusion => { :in => 1..25 }, :message => "Number of comments per page should be between 0 and 25"
  
  validates :style, :presence => true
  validates :title, :presence => true


  belongs_to :user
  belongs_to :style
  
  has_many :posts
  
end
