# JSON API for User objects
class UsersController < ApplicationController
  before_action :ensure_user_is_logged_in, only: [:create, :update, :destroy]
  before_action :ensure_user_is_admin, only: [:create, :update, :destroy]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    user_params = params.permit(:username, :password, :agent_id, :is_admin)
    @user = User.new(user_params)
    render json: @user.errors, status: 400 unless @user.save
  end

  def update
    @user = User.find(params[:id])
    if @user.nil?
      render json: { error: 'No user with specified ID exists!' }, status: 400
      return
    end
    user_params = params.permit(:username, :password, :agent_id, :is_admin)
    render json: @user.errors, status: 400 unless @user.update(user_params)
  end

  def destroy
    @user = User.find(params[:id])
    if @user.nil?
      render json: { error: 'No user with specified ID exists!' }, status: 400
      return
    end
    if @user.destroy
      head :no_content
    else
      render json: @user.errors, status: 400
    end
  end
end
