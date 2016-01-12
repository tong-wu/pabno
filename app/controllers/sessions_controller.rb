class SessionsController < ApplicationController
  def create
    @user = User.from_token(header['token'])
    if @user
      render json: { status: "success" }, status: 200
    else
      render json: { error: "Sorry, could not authorize user" }, status: 401
    end
  end

  #todo: Lol this definitely doesn't work right now
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
