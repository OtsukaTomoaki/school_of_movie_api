class Api::V1::SessionsController < Api::V1::ApplicationController
  skip_before_action :current_user, only: [:create, :remember_me]

  def create
    user = User.find_by(email: params[:email].downcase)
    if user && user.authenticate(params[:password])

      token = TokenService.issue_by_password!(params[:email], params[:password])
      user.remember
      render json: { token: token, remember_token: user.remember_token }, status: :ok
    else
      render json: { message: 'emailまたはpasswordが正しくありません' }, status: :unauthorized
    end
  end

  def remember_me
    user = User.find_by(email: params[:email].downcase)
    if user.authenticated?(params[:remember_token])
      token = TokenService.issue_by_remember_token!(params[:email], params[:remember_token])
      user.remember
      render json: { token: token, remember_token: user.remember_token }, status: :ok
    else
      render json: { message: 'emailまたはremember_tokenが正しくありません' }, status: :unauthorized
    end
  end
end
