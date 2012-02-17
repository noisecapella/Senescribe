require 'test_helper'

class UserTest < ActiveSupport::TestCase
  fixtures :users

  test "test_invalid_with_empty_attributes" do
    user = User.new
    assert !user.valid?
    assert user.errors.invalid?(:identity_url)
    assert user.errors.invalid?(:description)
    assert user.errors.invalid?(:email)
  end

  test "test_two_users_with_same_identity_url" do
    user_1 = User.find_by_description("George")
    user_2 = User.find_by_description("Other")

    user_2.identity_url = user_1.identity_url
    assert user_1.valid?
    assert !user_2.valid?
  end
end
