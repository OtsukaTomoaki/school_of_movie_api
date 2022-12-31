class ApplicationController < ActionController::API
  include SessionsHelper
  include CookiesHelper
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  skip_forgery_protection
  before_action :current_user

  def current_user
    begin
      @current_user ||= TokenService.authorization(request.headers['Authorization'])
    rescue => e
      p request.headers, e
      false
    end
  end

  def set_csrf_token

    cookies['CSRF-TOKEN'] = {
      domain: 'localhost:3000', # 親ドメイン
      value: form_authenticity_token
    }
  end
end
