class UsersController < ApplicationController
  def show
    render json: @user, status: 200
  end

  def create
    #todo: facebook?
  end

  def disable
    #todo: do we need?
  end

  private
  def get_user
    @user = User.find(params[:id])
  end
end
