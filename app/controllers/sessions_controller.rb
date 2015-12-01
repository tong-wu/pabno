class SessionsController < ApplicationController
  def create
    @user = User.from_omniauth(env["omniauth.auth"])
    if @user
      access_token = generate_access_token
      REDIS_LOGIN.set("token:#{access_token}", @user.oauth_token)
      REDIS_LOGIN.expireat("token:#{access_token}", 1.week.from_now.to_i)
      render json: { token: access_token }, status: 200
    else
      render json: { error: "Sorry, could not authorize user" }, status: 401
    end
  end

  def destroy
    destroy = REDIS_LOGIN.del("token:#{headers["Access-Token"]}")
    if destroy == 1
      render json: { status: "Logged out" }, status: 200
    else
      render json: { error: "Trouble logging out. Make sure the user isn't already logged out" }, status: 200
    end
  end

  def generate_access_token
    rand = SecureRandom.urlsafe_base64
    while !REDIS_LOGIN.get("token:#{rand}").nil? do
      rand = SecureRandom.urlsafe_base64
    end
    rand
  end
end
