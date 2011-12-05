class BlogController < ApplicationController
  def new
    if session[:user_id].nil? or User.find_by_id(session[:user_id]).nil?
      not_logged_in
      return
    end

    @blog = Blog.new
    @styles = Style.find(:all) 
  end

  def edit
    if session[:user_id].nil? or User.find_by_id(session[:user_id]).nil?
      not_logged_in
      return
    end
    
    @user = User.find(session[:user_id])
    @blog = @user.blog
    if @blog.nil?
      flash[:notice] = "Can't edit blog; no blog to edit"
      redirect_to :controller => :welcome
      return
    end
    @styles = Style.find(:all)     
  end

  def update
    if session[:user_id].nil? or User.find_by_id(session[:user_id]).nil?
      not_logged_in
      return
    end

    @user = User.find(session[:user_id])
    if @user.blog.nil?
      flash[:notice] = "Can't update a missing blog"
      redirect_to :controller => :welcome
      return
    end
    
    @blog = @user.blog
    if @blog.update_attributes(params[:blog])
      flash[:notice] = "Blog updated successfully"
    else
      flash[:notice] = "Unable to update blog" + get_errors
    end
    redirect_to :action => :show, :id => @blog
  end

  def index
    @user = User.find_by_id(session[:user_id])
    
    if @user.nil? or @user.blog.nil?
      redirect_to :controller => :welcome, :action => :index
      
    else
      @blog = @user.blog
      redirect_to :action => :show, :id => @user.blog
    end
  end

  def create
    @blog = Blog.new(params[:blog])
    if session[:user_id].nil?
      not_logged_in
      return
    end

    @user = User.find(session[:user_id])
    if !@user.blog.nil?
      flash[:notice] = "You already have a blog, cannot create a second one."
      redirect_to :action => :show, :id => @user.blog.id
      return
    end
    
    @blog.user = @user

    @blog.id = session[:user_id]
    if @blog.save
      flash[:notice] = "Blog created"
      redirect_to :action => :show, :id => @blog
    else
      flash[:notice] = "Blog didn't save" + get_errors
      redirect_to :controller => :welcome, :action => :index
    end
  end

  def show
    @blog = Blog.find(params[:id])
    @user = User.find_by_id(session[:user_id]) if confirm_logged_in_id_equals_given_id

    @offset = params[:offset].to_i
    @offset ||= 0
    @offset = 0 if @offset < 0
  end

  def new_post
    @user = User.find_by_id(session[:user_id]) 
    
    @blog = @user.blog
    if !@blog.autosaved_post_id.nil?
      @post = Post.find(@blog.autosaved_post_id)
    else
      @post = Post.new
    end
    @post.blog = @blog
    @post.is_viewable = false
    if @post.save
      flash[:notice] = "Create new post"
      redirect_to :controller => :post, :action => :edit, :id => @post
    else
      flash[:notice] = "Could not create new post"
      redirect_to :action => :show, :id => @blog
    end
    
  end
  def rss
    @blog = Blog.find(params[:id])
    
    @offset = params[:offset].to_i
    @offset ||= 0
    @offset = 0 if @offset < 0

    respond_to do |format|
      format.xml { render :layout => false }
    end
  end

  protected
  def not_logged_in
    flash[:notice] = "Not logged in"
    redirect_to :controller => :welcome, :action => :index
  end

  def confirm_logged_in_id_equals_given_id
    session_user_id = session[:user_id]
    blog = Blog.find_by_id(params[:id])
    param_user_id = blog.user.id
    
    if session_user_id.to_i != param_user_id.to_i
      return false
    else
      return true
    end
  end

  def get_errors
    Shared.get_errors(@blog, [:title, :user, :style, :posts_per_page, :comments_per_page])
  end
  


  
end
