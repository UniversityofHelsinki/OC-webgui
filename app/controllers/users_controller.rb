# JSON API for User objects
class UsersController < ApplicationController
  before_action :ensure_user_is_logged_in, only: :create
  before_action :ensure_user_is_admin, only: :create
  def index
    @users = User.all
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: { username: @user.username, id: @user.id, is_admin: @user.is_admin }, status: 201
    else
      render json: @user.errors, status: 400      
    end
  end

  def user_params
    params.require(:user).permit(:username, :password, :agent_id, :is_admin)
  end
end
