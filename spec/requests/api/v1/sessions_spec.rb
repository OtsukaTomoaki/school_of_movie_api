require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  let!(:user) {
    FactoryBot.create(:user,
    name: 'signin shitatou',
    email: "shitatou@gmail.com")
  }

  let!(:headers) {
    {
      'Content-Type'=> 'application/json'
    }
  }

  # ID, password認証は廃止する
  xcontext 'サインイン処理の検証' do
    let!(:signin_params) {
      {
        email: 'shitatou@gmail.com'
      }.to_json
    }

    let!(:invalid_email_signin_params) {
      {
        email: 'shitatou_ze@gmail.com'
      }.to_json
    }

    let!(:invalid_password_signin_params) {
      {
        email: 'shitatou@gmail.com'
      }.to_json
    }
    it '正しいID, Passwordをリクエストした場合、トークンを取得できる' do
      post '/api/v1/sessions', params: signin_params, headers: headers

      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['token'].split('.').length).to be >= 3
      expect(json['remember_token']).to_not be_empty
    end

    it '誤ったID, 正しいPasswordをリクエストした場合、トークンを取得できない' do
      post '/api/v1/sessions', params: invalid_email_signin_params, headers: headers

      expect(response).to have_http_status 401
      json = JSON.parse(response.body)
      expect(json['message']).to eq('emailまたはpasswordが正しくありません')
    end

    it '正しいID, 誤ったPasswordをリクエストした場合、トークンを取得できない' do
      post '/api/v1/sessions', params: invalid_password_signin_params, headers: headers

      expect(response).to have_http_status 401
      json = JSON.parse(response.body)
      expect(json['message']).to eq('emailまたはpasswordが正しくありません')
    end
  end

  context 'remenber_me処理の検証' do
    let(:remember_me_params) {
      user.remember
      {
        email: 'shitatou@gmail.com',
        remember_token: user.remember_token
      }.to_json
    }

    let(:old_remember_me_params) {
      user.remember
      params = {
        email: 'shitatou@gmail.com',
        remember_token: user.remember_token
      }.to_json
      user.remember
      params
    }

    it '正しいID, remember_tokenをリクエストした場合、トークンを取得できる' do
      post '/api/v1/sessions/remember_me', params: remember_me_params, headers: headers

      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['token'].split('.').length).to be >= 3
      expect(json['remember_token']).to_not be_empty
    end

    it '正しいID,古いremember_tokenをリクエストした場合、トークンを取得できない' do
      post '/api/v1/sessions/remember_me', params: old_remember_me_params, headers: headers

      expect(response).to have_http_status 401
      json = JSON.parse(response.body)
      expect(json['message']).to eq('emailまたはremember_tokenが正しくありません')
    end
  end
end
