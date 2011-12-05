class Blog < ActiveRecord::Base
  validates_presence_of :user
  validates_uniqueness_of :user_id
  
  validates_presence_of :posts_per_page, :comments_per_page
  validates_inclusion_of(:posts_per_page, 
                         :in => 1..100,
                         :message => "Number of posts per page should be between 0 and 100")
  validates_inclusion_of(:comments_per_page, 
                         :in => 1..25,
                         :message => "Number of comments per page should be between 0 and 25")
  

  validates_presence_of :style, :title


  belongs_to :user
  belongs_to :style
  
  has_many :posts
  
end
