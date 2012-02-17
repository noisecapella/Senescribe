class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :comments
  #has_many :words, :order => :current_index
  serialize :serialized_words

  validates :blog, :precense => true
end
