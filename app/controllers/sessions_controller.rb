class SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create

  def index
    set_csrf_token

    render status: 200, json: { status: 200 }

  end

  def create
    if (user = User.find_or_create_from_auth_hash(auth_hash))
      log_in user
    end
    redirect_to ENV['ROOT_URL']
  end

  def destroy
    log_out
    redirect_to ENV['ROOT_URL']
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
