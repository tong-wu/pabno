class SessionsController < ApplicationController
  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    REDIS.incr('users-logged-in')
    redirect_to root_path
  end

  def destroy
    session[:user_id] = nil
    REDIS.decr('users-logged-in')
    redirect_to root_path
  end

  def login
    render 'login'
  end
end
