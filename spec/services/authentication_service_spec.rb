require 'rails_helper'

RSpec.describe AuthenticationService, type: :service do
  pending "add some examples to (or delete) #{__FILE__}"

  let!(:user) do
    FactoryBot.create(:user,
      name: 'Nancy Molgan',
      email: 'nancy-pancy-denpcy@gmail.com',
      password: 'saikyounoP@ssw0rd')
  end

  describe "authenticate_user_with_password!" do
    it "email, passwordが正しい場合" do
      expect(AuthenticationService.authenticate_user_with_password!(
        'nancy-pancy-denpcy@gmail.com',
        'saikyounoP@ssw0rd').email).to eq 'nancy-pancy-denpcy@gmail.com'
    end
  end

  describe 'authenticate_user_with_token' do
    let!(:jwt) { jwt = TokenService.issue_by_password!(user.email, user.password) }
    it "正しいjwtが引数に指定された場合、ユーザの情報を取得できる" do
      expect(AuthenticationService.authenticate_user_with_token!(jwt)).to eq user
    end
  end
end