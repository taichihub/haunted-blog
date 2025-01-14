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
    raise ActiveRecord::RecordNotFound if !(@blog.owned_by?(current_user) && @blog.destroy!)

    redirect_to blogs_path, notice: 'Blog was successfully destroyed.', status: :see_other
  end

  private

  def set_user_blog
    @blog = current_user.blogs.find(params[:id])
  end

  def set_blog_with_authority_check
    @blog = Blog.find(params[:id])
    raise ActiveRecord::RecordNotFound if @blog.secret && (!current_user || (@blog.user_id != current_user.id))
  end

  def blog_params
    permitted = %i[title content secret]
    permitted << :random_eyecatch if current_user.premium?
    params.require(:blog).permit(*permitted)
  end
end
