require 'test_helper'

class PostTest < ActiveSupport::TestCase
  fixtures :posts
  test "test_has_blog" do
    post = Post.find_by_subject("Post 1")
    assert post.valid?
    post.blog = nil
    assert !post.valid?
  end
end
