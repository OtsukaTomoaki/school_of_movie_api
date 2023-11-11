class ApplicationController < ActionController::API
  include SessionsHelper
  include CookiesHelper
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  skip_forgery_protection
  before_action :current_user

  def current_user
    begin
      @current_user ||= TokenService.authorization(authorization_token)
    rescue => e
      p request.headers, e
      false
    end
  end

  def set_csrf_token

    cookies['CSRF-TOKEN'] = {
      domain: ENV['DOMAIN'], # 親ドメイン
      value: form_authenticity_token
    }
  end

  def authorization_token
    return @authorization_token if @authorization_token.present?
    auth_header = request.headers['Authorization'].present? ? request.headers['Authorization'] : request.cookies["authorization"]
    @authorization_token = auth_header.split(' ').last if auth_header
    @authorization_token
  end
end
