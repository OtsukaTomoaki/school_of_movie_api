class AuthenticationService
  include CustomException

  def self.authenticate_user_with_token!(token)
    rsa_private = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key')))
    begin
      decoded_token = JWT.decode(token, rsa_private, true, { algorithm: 'RS256' })
    rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
      raise UnAuthorizationError
    end
    user_id = decoded_token.first["sub"]
    user = User.find(user_id)
    raise UnAuthorizationError if user.nil?

    user
  end

  def self.authenticate_user_with_password!(email, password)
    user = User.find_by(email: email)&.authenticate(password)
    raise UnAuthorizationError if user.nil?

    user
  end

  def self.authenticate_user_with_remenber_token!(email, remember_token)
    user = User.find_by(email: email)

    raise UnAuthorizationError unless user.authenticated? remember_token

    user
  end

  def self.authenticate_user_with_social_account!(email, social_account_id, social_type)
    mapping = SocialAccountMapping.find_by(
                email: email,
                social_account_id: social_account_id,
                social_id: SocialAccountMapping.social_ids[social_type])

    raise UnAuthorizationError unless mapping and user = User.find_by(email: mapping.email)
    user
  end
end