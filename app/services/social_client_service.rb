class SocialClientService
  include CustomException

  GOOGLE_PROFILE_URL = ENV['GOOGLE_PROFILE_URL']

  class << self
    def create_accounts_with_google_profile!(token)
      profile = fetch_google_accounts_profile(token)
      user = User.new({
        email: profile['email'],
        name: profile['name']
      })
      avator_image = fetch_google_accounts_picture(profile['picture'])

      user.avator_image.attach(io: avator_image, filename: "#{Time.now.to_i}_#{user.id}.jpg" , content_type: "image/jpeg" )

      ActiveRecord::Base.transaction do
        user.save!(validate: false)
        SocialAccountMapping.create!({
          social_id: SocialAccountMapping.social_ids[:google],
          email: user.email,
          social_account_id: profile['id']
        })
      end
    end

    private
      def fetch_google_accounts_profile(token)
        header = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{token}"
        }
        query = { }
        client = HTTPClient.new
        response = client.get(GOOGLE_PROFILE_URL, header: header, query: query)

        JSON.parse(response.body)
      end

      def fetch_google_accounts_picture(url)
        header = { 'Content-Type' => 'image/jpg' }
        client = HTTPClient.new
        response = client.get(url, header: header)
        ImageService.convert_binary2file!(response.body.b)
      end
  end
end