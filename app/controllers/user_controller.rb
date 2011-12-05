class UserController < ApplicationController
# session_controller.rb
  def login
  end

  def add_friend
    @user = User.find_by_id(session[:user_id])
    if @user.nil?
      flash[:notice] = "User isn't logged in"
      redirect_to :controller => :welcome
      return
    end

    added_friend = User.find_by_id(params[:id])
    if added_friend == @user
      flash[:notice] = "Cannot add yourself as a friend"
      redirect_to :action => :profile
      return
    end
    
    if added_friend.nil?
      flash[:notice] = "Could not find user with id %s" % params[:id].to_s
      redirect_to :controller => :welcome
      return
    end

    if @user.users.include? added_friend
      flash[:notice] = "Friend already added"
      redirect_to :action => :profile
      return
    end

    @user.users << added_friend

    if !@user.save
      flash[:notice] = "Could not add friend"
      redirect_to :controller => :welcome
      return
    end
    flash[:notice] = "Friend added."
    redirect_to :action => :profile, :id => @user
  end

  def remove_friend
    @user = User.find_by_id(session[:user_id])
    if @user.nil?
      flash[:notice] = "User isn't logged in"
      redirect_to :controller => :welcome
      return
    end

    @removed_friend = User.find_by_id(params[:id])
    if @removed_friend.nil?
      flash[:notice] = "Could not find user with id %s" % params[:id].to_s
      redirect_to :controller => :welcome
      return
    end

    @user.users.delete(@removed_friend)
    if !@user.save
      flash[:notice] = "Could not remove friend"
      redirect_to :controller => :welcome
      return
    end

    flash[:notice] = "Friend deleted"
    redirect_to :action => :profile, :id => @user
  end

  def change_friends
    @user = User.find_by_id(session[:user_id])
    if @user.nil?
      flash[:notice] = "User isn't logged in"
      redirect_to :controller => :welcome
      return
    end

    @friends = @user.users
  end

  def create
    begin
      open_id_authentication(params[:openid_url])
    rescue OpenIdAuthentication::InvalidOpenId => e
      redirect_to_index "OpenID authentication failed: '%s'" % e.message
    end
  end

  def destroy
    @user = User.find_by_id(session[:user_id])
    if @user.nil?
      redirect_to_index "You aren't logged in, so you can't be logged out."
    else
      cookies.delete :auth_token
      reset_session
      
      redirect_to_index "You have been logged out."
    end
  end
  
  def edit
    if !confirm_logged_in_id_equals_given_id
      return
    end
    @user = User.find(params[:id])
  end
  
  def profile
    id = params[:id] || session[:user_id]
    if id.nil?
      redirect_to_index "Couldn't find user without an ID"
      return
    end
    @user = User.find(id)
  end

  def index
    redirect_to :action => :profile
  end
  
  def logout
    destroy
  end

  def create_new_user
    @user = User.new(params[:user])
    if session[:identity_url].nil?
      redirect_to_index "You didn't sign in using OpenID"
      return
    end
    @user.identity_url = session[:identity_url]
    
    
    if @user.save
      successful_login
    else
      message = "Unable to create new user" + get_errors
      redirect_to_index message
    end
  end

  def update
    if !confirm_logged_in_id_equals_given_id
      return
    end
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "User updated successfully"
    else
      flash[:notice] = "Unable to update user" + get_errors
    end
    redirect_to :action => :profile, :id => params[:id]
  end
  ##PROTECTED
  protected
  
  def get_errors
    Shared.get_errors(@user, [:identity_url, :description, :email])
  end

  def confirm_logged_in_id_equals_given_id
    session_user_id = session[:user_id]
    param_user_id = params[:id]
    if session_user_id.to_i != param_user_id.to_i
      redirect_to_index("You aren't logged in as that user, so you can't edit their profile.")
      return false
    else
      return true
    end
  end


  def logged_in?
    session[:user_id]
  end

  def open_id_authentication(openid_url)
    authenticate_with_open_id(openid_url) do |result, identity_url|
      if result.successful?
        @user = User.find_or_initialize_by_identity_url(identity_url)
        if @user.new_record?
          @user = nil
          session[:identity_url] = identity_url
          render :action => :fill_new_fields
          return
        end
        
        
        successful_login
      else
        failed_login result.message
      end
    end
  end

  def failed_login(message = "Authentication failed.")
    redirect_to_index(message)
  end
  
  def successful_login
    session[:user_id] = @user.id
    session[:identity_url] = nil
    if params[:remember_me] == "1"
      cookies[:auth_token] = { :value => @user.remember_token , :expires => @user.remember_token_expires_at }
    end
    #redirect_back_or_default('/')
    flash[:notice] = "Logged in successfully"
    redirect_to :action => :profile, :id => @user.id
  end
  
  def redirect_to_index(text)
    flash[:notice] = text
    redirect_to :controller => :welcome
  end
  
end
