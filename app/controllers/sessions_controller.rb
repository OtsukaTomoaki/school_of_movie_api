class SessionsController < ApplicationController
  skip_before_action :check_logged_in, only: :create

  def index
    set_csrf_token

    render status: 200, json: { status: 200 }

  end

  def create
    auth_hash_param = auth_hash
    converted_param = AuthParamConverter.ConvertGoogleAuth2User(auth_hash_param)
    if (user = User.find_by(email: converted_param[:email]))
      log_in user
      redirect_to ENV['ROOT_URL']
    else
      google_token = auth_hash['credentials']['token']
      onetime_token = OneTimeToken.create({ exchange_token: google_token })

      signup_json_str = {
        name: converted_param[:name],
        email: converted_param[:email],
        onetime_token: onetime_token.id
      }.to_json.to_s
      oauth_provider_json = URI.encode_www_form(signup_state: Base64.encode64(signup_json_str))
      redirect_to ENV['ROOT_URL'] + "signup_google?#{oauth_provider_json}"
    end
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
