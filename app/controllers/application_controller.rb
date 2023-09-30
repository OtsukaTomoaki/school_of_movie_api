class ApplicationController < ActionController::API
  include SessionsHelper
  include CookiesHelper
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  skip_forgery_protection
  before_action :current_user

  def current_user
    begin
      authorization_header = request.headers['Authorization'].present? ? request.headers['Authorization'] : request.cookies["authorization"]
      @current_user ||= TokenService.authorization(authorization_header)
    rescue => e
      p request.headers, e
      false
    end
  end

  def set_csrf_token

    cookies['CSRF-TOKEN'] = {
      domain: '192.168.32.138.nip.io:3000', # 親ドメイン
      value: form_authenticity_token
    }
  end
end
