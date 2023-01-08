require 'rails_helper'

RSpec.describe AuthenticationService, type: :service do
  pending "add some examples to (or delete) #{__FILE__}"

  let!(:user) do
    FactoryBot.create(:user,
      name: 'Nancy Molgan',
      email: 'nancy-pancy-denpcy@gmail.com',
      password: 'saikyounoP@ssw0rd')
  end

  context "authenticate_user_with_password!" do
    it "email, passwordが正しい場合" do
      expect(AuthenticationService.authenticate_user_with_password!(
        'nancy-pancy-denpcy@gmail.com',
        'saikyounoP@ssw0rd').email).to eq 'nancy-pancy-denpcy@gmail.com'
    end
  end
end