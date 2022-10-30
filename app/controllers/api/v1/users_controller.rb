class Api::V1::UsersController < ApplicationController
  def index
    @users = User.all
  end

  def create
    user = User.new(user_params)

    if user.save!
      @user = user
      return
    else
      response_internal_server_error
    end
  end

  private
  def user_params
    user = params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

end
