module AuthenticationHelper
  extend ActiveSupport::Concern

  included do
    before do
      user = User.create(
        name: 'user',
        email: "user@gmail.com",
        password: 'Bar1234')

      UserTag.create(
        user: user,
        tag: "tag_TAG_T@G"
      )
      allow(TokenService).to receive(:authorization).and_return(user)
    end
  end
end