class UsersController < ApplicationController
  def show
    render json: @user, status: 200
  end

  def disable
    if @user.disable_account
      render json: @user, status: 200
    else
      render json: { error: "Account could not be disabled"}
    end
  end

  private
  def get_user
    @user = User.find(params[:id])
  end
end
