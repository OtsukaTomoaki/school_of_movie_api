require 'rails_helper'

RSpec.describe AuthenticationService, type: :service do
  pending "add some examples to (or delete) #{__FILE__}"

  let!(:user) do
    User.create({
      name: 'Nancy Molgan',
      email: 'nancy-pancy-denpcy@gmail.com',
      password: 'saikyounoP@ssw0rd',
      password_confirmation: 'saikyounoP@ssw0rd',
      activated: true,
      activated_at: Time.zone.now})
  end

  context "ログイン" do
    it "email, passwordが正しい場合" do
      expect(AuthenticationService.authenticate_user_with_password!(
        'nancy-pancy-denpcy@gmail.com',
        'saikyounoP@ssw0rd').email).to eq 'nancy-pancy-denpcy@gmail.com'
    end
  end
end