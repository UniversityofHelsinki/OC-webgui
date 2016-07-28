class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def create
    user = User.find_by(id: session[:user_id])
    render json: { error: 'Invalid session' }, status: 403 if user.nil?    
    render json: { error: 'Only administrators may create users' }, status: 403 unless user.is_admin

    @user = User.new(user_params)
    unless @user.save
      render json: @user.errors, status: 400
    else 
      render json: { username: @user.username, id: @user.id}, status: 201
    end
  end

  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :agent_id, :is_admin)
  end
end
