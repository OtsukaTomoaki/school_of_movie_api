module AuthenticationHelper
  extend ActiveSupport::Concern

  included do
    let!(:authenticated_user) {
      user = User.create(
        name: 'user',
        email: "user@gmail.com")
      allow(TokenService).to receive(:authorization).and_return(user)

      user
    }
  end
end