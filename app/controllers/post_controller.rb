class PostController < ApplicationController
protected
public
  def update
    @user = User.find_by_id(session[:user_id])
    @post = Post.find(params[:id])

    if is_incorrect_user
      return
    end
    
    @post.is_viewable = true
    @post.autosave_text = nil
    @blog = @user.blog
    @blog.autosaved_post_id = nil
    @blog.save
    
    @post.text = params[:post][:text].gsub("<", "&lt;").gsub(">", "&gt;")
    @post.subject = params[:post][:subject]

    if @post.save
      Shared.update_word_table @post.text, @post
      flash[:notice] = "Post successfully made"
    else
      flash[:notice] = "Post not saved."
    end
    redirect_to :controller => :blog
  end

  def show
    @post = Post.find(params[:id])

    if !@post.is_viewable
      flash[:notice] = "Post doesn't exist"
      redirect_to :controller => :blog
      return
    end

    @user = User.find_by_id(session[:user_id])
    @comments_per_page = @post.blog.comments_per_page
    @offset = params[:offset].to_i
    @offset ||= 0
    @offset = 0 if @offset < 0
  end

  def edit
    @user = User.find_by_id(session[:user_id])
    @post = Post.find(params[:id])
    
    if is_incorrect_user
      return
    end
    
    @blog = @post.blog
  end
  
  def update_edit
    @user = User.find_by_id(session[:user_id])
    @post = Post.find(params[:id])
    return if is_incorrect_user

    data = params[:post][:text].gsub("<", "&lt;").gsub(">", "&gt;")


    @post.autosave_text = data
    @post.save
    
    @blog = @user.blog
    @blog.autosaved_post_id = @post.id
    @blog.save

    Shared.update_word_table data, @post
    @post = Post.find(params[:id])  #retrieve updated info from database
  end

protected
  def is_incorrect_user
    if @user.nil? or @user.id != @post.blog.user.id
      flash[:notice] = "Can't write to a blog that's not your own"
      redirect_to :controller => :blog
      return true
    else
      return false
    end
  end

  
end
