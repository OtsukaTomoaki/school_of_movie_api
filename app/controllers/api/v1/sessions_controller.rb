class Api::V1::SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])

      token = TokenService.issue_by_password!(params[:email], params[:password])
      user.remember
      render json: { token: token, remember_token: user.remember_token }, status: :ok
    else
      render json: user.errors, status: :unauthorized
    end
  end
end
