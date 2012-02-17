require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  test "invalid_with_empty_attributes" do
    user = User.new
    assert !user.valid?
    empty = "can't be blank"
    message = user.errors.full_messages.to_s
    assert user.errors[:identity_url].first == empty, message
    assert user.errors[:description].first == empty, message
    assert user.errors[:email].first == empty, message
  end

  test "two_users_with_same_identity_url" do
    user_1 = User.find_by_description("George")
    user_2 = User.find_by_description("Other")

    user_2.identity_url = user_1.identity_url
    assert user_1.valid?, user_1.errors.full_messages.to_s
    assert !user_2.valid?
  end
end
