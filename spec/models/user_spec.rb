require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) do
    User.create({
      name: 'Nancy Molgan',
      email: 'nancy-pancy-denpcy@gmail.com',
      activated: true,
      activated_at: Time.zone.now})
  end

  xcontext "remember_tokenの検証" do
    it "remember_tokenの検証" do
      allow(User).to receive(:new_token).and_return('fGrEwArbI25PAtA1CWZsjQ')
      user.remember
      expect(user.remember_token).to eq 'fGrEwArbI25PAtA1CWZsjQ'
    end

    it "remember_digestの検証" do
      allow(User).to receive(:digest).and_return('$2a$12$HlV.cWnqunozZtWA2QlZPOrRZvLGTErdK7rBG1WXeoMbSGtR76NTm')
      user.remember
      expect(user.remember_digest).to eq '$2a$12$HlV.cWnqunozZtWA2QlZPOrRZvLGTErdK7rBG1WXeoMbSGtR76NTm'
    end

    it "remember_tokenのログイン" do
      user.remember
      expect(user.authenticated?(user.remember_token)).to eq true
    end

    it "remember_tokenのリフレッシュ" do
      user.remember
      remember_token = user.remember_token
      expect(user.authenticated?(remember_token)).to eq true
      user.remember
      expect(user.authenticated?(remember_token)).to eq false
    end
  end
end