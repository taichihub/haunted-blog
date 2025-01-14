# frozen_string_literal: true

class BlogsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show]

  before_action :set_user_blog, only: %i[edit update destroy]
  before_action :set_blog_with_authority_check, only: %i[show]

  def index
    @blogs = Blog.search(params[:term]).published.default_order
  end

  def show; end

  def new
    @blog = Blog.new
  end

  def edit
    raise ActiveRecord::RecordNotFound unless @blog.owned_by?(current_user)

    render :edit
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
    render(:edit, status: :unprocessable_entity) if !(@blog.owned_by?(current_user) && @blog.update(blog_params))

    redirect_to blog_url(@blog), notice: 'Blog was successfully updated.'
  end

  def destroy
    if @blog.owned_by?(current_user) && @blog.destroy!
      redirect_to blogs_path, notice: 'Blog was successfully destroyed.', status: :see_other
    else
      render file: "public/404.html", status: :not_found, layout: false
    end
  end

  private

  def set_user_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def set_blog_with_authority_check
    if current_user
      @blog = Blog.where(id: params[:id])
                  .where("secret = ? OR user_id = ?", false, current_user)
                  .where.not("secret = ? AND user_id != ?", true, current_user)
                  .first!
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
