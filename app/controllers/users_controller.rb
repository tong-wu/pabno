class UsersController < ApplicationController
  before_action :get_user, only: [:show, :disable]

  def show
    render json: @user, status: 200
  end

  def disable
    if @user.disable_account
      render json: @user, status: 200
    else
      render json: { error: "Account could not be disabled"}, status: 200
    end
  end

  private
  def get_user
    @user = User.find(params[:id])
  end
end
