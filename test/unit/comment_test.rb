require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  def test_invalid_with_empty_attributes
    comment = Comment.new
    assert !comment.valid?
  end
end
