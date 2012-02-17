require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  test "invalid_with_empty_attributes" do
    comment = Comment.new
    assert !comment.valid?
  end
end
