class TokenService
  include CustomException
  @rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))

  class << self
    def issue_by_password!(email, password)
      user = AuthenticationService.authenticate_user_with_password!(email, password)
      issue_token(user)
    end

    def issue_by_remember_token!(email, remember_token)
      user = AuthenticationService.authenticate_user_with_remenber_token!(email, remember_token)
      issue_token(user)
    end

    def issue_by_social_account(email, social_account_id, social_type)
      user = SocialAccountMapping.authenticate_user_with_social_account!(
              email,
              social_account_id,
              social_type
            )
      issue_token(user)
    end

    def authorization(auth_header)
      jwt = auth_header.split(' ')[1]
      jwt_payload = validate_jwt(jwt)
      if jwt_payload and not user = User.find(jwt_payload.first['sub'])
        raise InvalidJwtError
      end
      user
    end
    private

      def issue_token(user)
        payload = {
          sub: user.id,
          name: user.name,
          exp: (DateTime.current + 1.days).to_i
        }
        JWT.encode(payload, @rsa_private, "RS256")
      end

      def validate_jwt(token)
        begin
          decoded_token = JWT.decode(token, @rsa_private, true, { algorithm: 'RS256' })
        rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError => e
          raise e
        end
      end
  end
end