require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  fixtures :users

  def test_invalid_with_empty_attributes
    blog = Blog.new
    assert !blog.valid?
  end

  def test_initialize_two_blogs_with_different_users
    blog_1 = Blog.find_by_title("My Blog")
    blog_2 = Blog.find_by_title("Blog 2")


    assert blog_1.valid?
    assert blog_2.valid?
  end

  def test_initialize_two_blogs_with_same_user
    blog_1 = Blog.find_by_title("My Blog")
    blog_2 = Blog.find_by_title("Blog 2")
    blog_2.user = blog_1.user
    
    assert blog_1.valid?
    assert !blog_2.valid?
  end
  
  def test_blog_has_style
    blog = Blog.find_by_title("Blog 2")
    blog.style = nil
    assert !blog.valid?
  end

  def test_blog_has_title
    blog = Blog.find_by_title("Blog 2")
    blog.title = nil
    assert !blog.valid?
  end
end
