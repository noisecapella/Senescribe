require 'test_helper'

class BlogTest < ActiveSupport::TestCase
  fixtures :users

  test "invalid_with_empty_attributes" do
    blog = Blog.new
    assert !blog.valid?
  end

  test "initialize_two_blogs_with_different_users" do
    blog_1 = Blog.find_by_title("My Blog")
    blog_2 = Blog.find_by_title("Blog 2")


    assert blog_1.valid?, blog_1.errors.full_messages.to_s
    assert blog_2.valid?, blog_2.errors.full_messages.to_s
  end

  test "initialize_two_blogs_with_same_user" do
    blog_1 = Blog.find_by_title("My Blog")
    blog_2 = Blog.find_by_title("Blog 2")
    blog_2.user = blog_1.user
    
    assert blog_1.valid?, blog_1.errors.full_messages.to_s
    assert !blog_2.valid?
  end
  
  test "blog_has_style" do
    blog = Blog.find_by_title("Blog 2")
    blog.style = nil
    assert !blog.valid?
  end

  test "blog_has_title" do
    blog = Blog.find_by_title("Blog 2")
    blog.title = nil
    assert !blog.valid?
  end

  
end
