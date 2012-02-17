require 'test_helper'

class UserControllerTest < ActionController::TestCase
  fixtures :users
  #CREATE
  test "test_create_with_empty_openid" do
    get :create 
    assert_redirected_to_index "OpenID authentication failed: ' is not an OpenID URL'"
  end

  test "test_create_with_url_which_is_not_a_openid_server" do
    get :create, { :openid_url => "www.google.com"}
    assert_redirected_to_index "Sorry, the OpenID server couldn't be found"
  end
  
  test "test_create_with_invalid_url" do
    get :create, {:openid_url => "..." }
    assert_redirected_to_index "OpenID authentication failed: '... is not an OpenID URL'"
  end

  #LOGOUT
  test "test_log_out" do
    user = User.find_by_description("George")
    get :logout, {}, {:user_id => user.id}
    assert_redirected_to_index "You have been logged out."
  end

  #EDIT
  test "test_edit_while_logged_in" do
    user = User.find_by_description("George")
    get :edit, {:id => user.id}, {:user_id => user.id}
    
    assert_response :success
  end
  
  test "test_edit_while_not_logged_in" do
    user = User.find_by_description("George")
    get :edit, {:id => user.id}
    assert_redirected_to_index "You aren't logged in as that user, so you can't edit their profile."
  end
  test "test_edit_while_logged_in_as_a_different_user" do
    user = User.find_by_description("George")
    get :edit, {:id => user.id}, {:user_id => user.id + 1}
    assert_redirected_to_index "You aren't logged in as that user, so you can't edit their profile."
  end

  test "test_edit_of_incorrect_user" do
    assert_raise (ActiveRecord::RecordNotFound) do 
      get :edit, {:id => -1}, {:user_id => -1}
    end    
  end

  #PROFILE
  test "test_profile_view" do
    user = User.find_by_description("George")
    get :profile, {:id => user.id}
    
    assert_response :success
  end

  test "test_profile_view_without_id" do
    get :profile
    
    assert_redirected_to_index("Couldn't find user without an ID")
  end

  test "test_profile_view_of_invalid_id" do
    assert_raise(ActiveRecord::RecordNotFound) do
      get :profile, {:id => 0}
    end
  end
  
  #CREATE_NEW_USER
  test "test_create_new_user_without_being_authenticated" do
    params = {:user => {:email => "e@f.g", :description => "Description"}}
    get :create_new_user, params
    assert_redirected_to_index "You didn't sign in using OpenID"
  end
  
  test "test_create_new_user" do
    params = {:user => {:email => "e@f.g", :description => "Description"}}
    session = {:identity_url => "http://e.com"}
    get :create_new_user, params, session
    assert_equal "Logged in successfully", flash[:notice]
    user = User.find_by_email("e@f.g")
    assert_redirected_to :action => :profile, :id => user.id
  end
  
  #UPDATE
  test "test_update_while_logged_in_as_different_user" do
    user = User.find_by_description("George")
    params = {:user => {:email => "t", :description => "u"},
      :id => user.id}
    session = {:user_id => user.id + 1}
    
    get :update, params, session
    #assert_redirected_to :action => :profile, :id => params[:id]
    assert_redirected_to_index "You aren't logged in as that user, so you can't edit their profile."
  end
  
  test "test_update_while_not_logged_in" do
    user = User.find_by_description("George")
    params = {:user => {:email => "t", :description => "u"},
      :id => user.id}
    get :update, params
    
    assert_redirected_to_index "You aren't logged in as that user, so you can't edit their profile."
  end

  test "test_update_invalid_user_id" do
    params = {:user => {:email => "t", :description => "u"},
      :id => -1}
    session = {:user_id => -1}

    assert_raise(ActiveRecord::RecordNotFound) do
      get :update, params, session      
    end
  end

  test "test_update_with_missing_email" do
    user = User.find_by_description("George")
    params = {:user => {:email => "", :description => "u"}, :id => user.id}
    session = {:user_id => user.id}
    get :update, params, session
    assert_equal "Unable to update user: identity_url is missing, description is missing, email is missing", flash[:notice]
    assert_redirected_to :action => :profile, :id => user.id
  end

  protected
  def assert_redirected_to_index(text)
    assert_equal text, flash[:notice]
    assert_redirected_to :controller => :welcome, :action => :index    
  end
end
