class ApplicationController < ActionController::API
  include SessionsHelper
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  skip_forgery_protection
  before_action :check_logged_in

  # protect_from_forgery
  def check_logged_in
    # return if current_user
    # redirect_to ENV['ROOT_URL']
  end

  def set_csrf_token

    cookies['CSRF-TOKEN'] = {
      domain: 'localhost:3000', # 親ドメイン
      value: form_authenticity_token
    }
  end
end
