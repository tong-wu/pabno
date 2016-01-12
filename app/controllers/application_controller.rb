class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  before_action :current_user, only: [:check_login]

  def current_user
    @current_user ||= User.where(:oauth_token => REDIS_LOGIN.get("token:#{headers["Access-Token"]}")).first if headers["Access-Token"]
  end

  def check_login
    if !@current_user || @current_user.nil?
      render json: { status: "Unauthorized" } , status: 401
    end
  end
end
