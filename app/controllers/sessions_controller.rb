class SessionsController < ApplicationController
  skip_before_action :current_user, only: :create

  def index
    set_csrf_token

    render status: 200, json: { status: 200 }
  end

  def create
    auth_hash_param = auth_hash
    converted_param = AuthParamConverter.ConvertGoogleAuth2User(auth_hash_param)
    if (user = AuthenticationService.authenticate_user_with_social_account!(
        converted_param[:email],
        auth_hash_param.uid,
        :google))
      user.remember

      signin_json_str = {
        email: user.email,
        remember_token: user.remember_token
      }.to_json.to_s

      add_authorization_cookie(
        TokenService.issue_by_social_account(converted_param[:email], auth_hash_param.uid, :google)
      )

      query = URI.encode_www_form(signin_state: Base64.encode64(signin_json_str))
      redirect_to ENV['ROOT_URL'] + "signin_with_token?#{query}"
    else
      google_token = auth_hash['credentials']['token']
      onetime_token = OneTimeToken.create({ exchange_json: {
          social_id: SocialAccountMapping.social_ids[:google],
          token: google_token
        }
      })

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
