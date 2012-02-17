require 'test_helper'

class BlogControllerTest < ActionController::TestCase
  fixtures :users

  #NEW
  test "new_while_not_logged_in" do
    get :new
    assert_redirected_to_index "Not logged in"
  end

  test "new" do
    user = User.find_by_description("George")
    get :new, {}, {:user_id => user.id}
    assert_response :success
  end

  #CREATE
  test "create_empty_blog" do
    user = User.find_by_description("Blogless Joe")
    get :create, {}, {:user_id => user.id}
    assert_redirected_to_index "Blog didn't save: title is missing, style is missing, posts_per_page is missing, comments_per_page is missing"
  end

  test "create second blog" do
    user = User.find_by_description("George")
    get :create, {}, {:user_id => user.id}
    assert_redirected_to({:action => :show, :id => user.blog.id}, "You already have a blog, cannot create a second one.")
  end

  test "create_blog_while_not_logged_in" do
    style = Style.find_by_name("default")
    get :create, {:blog => {}}

    assert_redirected_to_index "Not logged in"
  end

  protected
  def assert_redirected_to_index(text)
    assert_equal text, flash[:notice]
    assert_redirected_to :controller => :welcome, :action => :index    
  end
end
