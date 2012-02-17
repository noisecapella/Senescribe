require 'test_helper'

class BlogControllerTest < ActionController::TestCase
  fixtures :users

  #NEW
  test test_new_while_not_logged_in do
    get :new
    assert_redirected_to_index "Not logged in"
  end

  test "test_new" do
    user = User.find_by_description("George")
    get :new, {}, {:user_id => user.id}
    assert_response :success
  end

  #CREATE
  test "test_create_empty_blog" do
    user = User.find_by_description("George")
    get :create, {}, {:user_id => user.id}
    assert_redirected_to_index "Blog didn't save: title is missing, style is missing"
  end

  test "test_create_blog_while_not_logged_in" do
    style = Style.find_by_name("default")
    get :create, {:blog => {:style => style, :title => "title"}}

    assert_redirected_to_index "FAIL"
  end

  protected
  def assert_redirected_to_index(text)
    assert_equal text, flash[:notice]
    assert_redirected_to :controller => :welcome, :action => :index    
  end
end
