class CommentController < ApplicationController
  def create
    if session[:user_id].nil?
      flash[:notice] = "User not logged in"
      redirect_to :controller => :welcome
      return
    end

    @comment = Comment.new(params[:comment])
    @comment.user = User.find_by_id(session[:user_id])
    if @comment.save
      flash[:notice] = "Comment created successfully"
    else
      flash[:notice] = "Comment had an error"
    end
    redirect_to :controller => :post, :action => :show, :id => @comment.post.id

  end
end

