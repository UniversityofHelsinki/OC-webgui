# Handle user authentication using sessions.
class SessionController < ApplicationController
  def create
    user = User.find_by username: params[:username]
    return render json: { error: 'invalid username' }, status: :unauthorized if user.nil?
    unless user.authenticate(params[:password])
      return render json: { error: 'wrong password' }, status: :unauthorized
    end
    session[:user_id] = user.id
    render json: user
  end

  def destroy
    session[:user_id] = nil
    render nothing: true
  end
end
