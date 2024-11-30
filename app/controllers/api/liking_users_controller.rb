# frozen_string_literal: true

class Api::LikingUsersController < ApplicationController
  def index
    blog = Blog.find(params[:blog_id])
    @users = blog.liking_users.order(:id)
    my_liking = blog.likings.find_by(user: current_user)
    @destroy_path = my_liking ? api_blog_liking_path(blog, my_liking, format: :json) : nil
    users_json = @users.as_json(only: %i[id created_at updated_at nickname premium])
    response_data = { users: users_json, destroy_path: @destroy_path }
    render json: response_data
  end
end
