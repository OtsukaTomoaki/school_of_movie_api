require 'rails_helper'

RSpec.describe TokenService, type: :service do
  let!(:rsa_private) { OpenSSL::PKey::RSA.new(File.read(Rails.root.join('auth/service.key'))) }
  let!(:algorithm) { 'RS256' }
  let!(:user) {
    FactoryBot.create(:user,
      name: 'FOO_BAR_テスト',
      email: 'foo_bar_baz@sample.com',
      password: 'pass1234')
  }
  let!(:social_account_mapping) {
    FactoryBot.create(:social_account_mapping,
      social_id: 1,
      email: user.email,
      social_account_id: '1234')
  }

  describe "issue_by_password!" do
    context "存在するユーザのemail, passwordが引数に指定された場合" do
      it "jwtが返されること" do
        jwt = TokenService.issue_by_password!('foo_bar_baz@sample.com', 'pass1234')
        payload = JWT.decode(jwt, rsa_private, true, { algorithm: 'RS256' })

        expect(payload.first['sub']).to eq user.id
        expect(payload.first['name']).to eq user.name
        expect(payload.last['alg']).to eq algorithm
      end
    end
  end

  describe "issue_by_remember_token!" do
    context "存在するユーザのemail, remember_tokenが引数に指定された場合" do
      it 'jwtが返されること' do
        user.remember
        jwt = TokenService.issue_by_remember_token!('foo_bar_baz@sample.com', user.remember_token)
        payload = JWT.decode(jwt, rsa_private, true, { algorithm: 'RS256' })
        expect(payload.first['sub']).to eq user.id
        expect(payload.first['name']).to eq user.name
        expect(payload.last['alg']).to eq algorithm
      end
    end
  end

  describe "issue_by_social_account" do
    context "存在するユーザのemail, social_account_id, social_typeが引数に指定された場合" do
      it 'jwtが返されること' do
        jwt = TokenService.issue_by_social_account('foo_bar_baz@sample.com', '1234', :google)
        payload = JWT.decode(jwt, rsa_private, true, { algorithm: 'RS256' })
        expect(payload.first['sub']).to eq user.id
        expect(payload.first['name']).to eq user.name
        expect(payload.last['alg']).to eq algorithm
      end
    end
  end

  describe "authorization" do
    context "存在するユーザのauth_headerが引数に指定された場合" do
      it 'ユーザが返されること' do
        jwt = TokenService.issue_by_password!(user.email, user.password)
        authorization_user = TokenService.authorization("bearer #{jwt}")
        expect(authorization_user).to eq user
      end
    end
  end
end