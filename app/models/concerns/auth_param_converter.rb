module AuthParamConverter
  extend ActiveSupport::Concern

  def self.ConvertGoogleAuth2User(auth_hash)
    {
      name: auth_hash.info.name,
      email: auth_hash.info.email,
      # image: auth_hash.info.image,
    }
  end
end