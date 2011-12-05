require 'test_helper'

class PostTest < ActiveSupport::TestCase
  fixtures :posts
  def test_has_blog
    post = Post.find_by_subject("Post 1")
    assert post.valid?
    post.blog = nil
    assert !post.valid?
  end
end
