require 'rails_helper'

RSpec.describe "Api::V1::Sessions", type: :request do
  let!(:user) {
    FactoryBot.create(:user,
    name: 'signin shitatou',
    email: "shitatou@gmail.com",
    password: 'shitatou1234')
  }

  let!(:signin_params) {
    {
      email: 'shitatou@gmail.com',
      password: 'shitatou1234'
    }.to_json
  }

  let!(:invalid_email_signin_params) {
    {
      email: 'shitatou_ze@gmail.com',
      password: 'shitatou1234'
    }.to_json
  }

  let!(:invalid_password_signin_params) {
    {
      email: 'shitatou@gmail.com',
      password: 'shitatou12345678'
    }.to_json
  }

  let!(:signin_headers) {
    {
      'Content-Type'=> 'application/json'
    }
  }

  context 'サインイン処理の検証' do
    it '正しいID, Passwordをリクエストした場合、トークンを取得できる' do
      post '/api/v1/sessions', params: signin_params, headers: signin_headers

      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['token'].split('.').length).to be >= 3
      expect(json['remember_token']).to_not be_empty
    end

    it '誤ったID, 正しいPasswordをリクエストした場合、トークンを取得できる' do
      post '/api/v1/sessions', params: invalid_email_signin_params, headers: signin_headers

      expect(response).to have_http_status 401
      json = JSON.parse(response.body)
      expect(json['message']).to eq('emailまたはpasswordが正しくありません')
    end

    it '正しいID, 誤ったPasswordをリクエストした場合、トークンを取得できる' do
      post '/api/v1/sessions', params: invalid_password_signin_params, headers: signin_headers

      expect(response).to have_http_status 401
      json = JSON.parse(response.body)
      expect(json['message']).to eq('emailまたはpasswordが正しくありません')
    end
  end
end
