# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_user_blog, only: %i[edit update destroy]
  before_action :set_blog_with_authority_check, only: %i[show edit update destroy]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit
    if @blog.owned_by?(current_user)
      render :edit
    else
      redirect_to blog_path(@blog), alert: 'You are not authorized to edit this blog.'
    end
  end

  def create
    @blog = current_user.blogs.new(blog_params)

    if @blog.save
      redirect_to blog_url(@blog), notice: 'Blog was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog.owned_by?(current_user) && @blog.update(blog_params)
      redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog.owned_by?(current_user) && @blog.destroy!
      redirect_to blogs_path, notice: 'Blog was successfully destroyed.', status: :see_other
    else
      redirect_to blog_path(@blog), alert: 'You are not authorized to destroy this blog.'
    end
  end

  private

  def set_user_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def set_blog_with_authority_check
    if current_user
      @blog = Blog.where(id: params[:id])
            .where("secret != ? OR user_id = ?", true, current_user)
            .first!
      redirect_to blogs_path, alert: 'You are not authorized to access this blog.' if @blog.secret? && @blog.user != current_user
    else
      @blog = Blog.where(id: params[:id])
                  .where.not(secret: true)
                  .first!
    end
  end

  def blog_params
    permitted = %i[title content secret]
    permitted << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(*permitted)
  end
end
