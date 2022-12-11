module AuthenticationHelper
  extend ActiveSupport::Concern

  included do
    before do
      allow(TokenService).to receive(:authorization).and_return(User.create(
        name: 'user',
        email: "user@gmail.com",
        password: 'Bar1234'))
    end
  end
end