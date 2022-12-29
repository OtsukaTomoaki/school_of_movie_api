require 'rails_helper'

RSpec.describe "Api::V1::User", type: :request, authentication: :skip  do
  describe "GET /index" do
    it 'プロフィールを取得する' do
      5.times do |i|
        user = FactoryBot.create(:user,
          name: 'Foo婆バズ',
          email: "#{i}_bar@gmail.com",
          password: 'Bar1234')
      end

      get '/api/v1/users/profile'
      json = JSON.parse(response.body)

      expect(response.status).to eq(200)

      expect(json['name']).to eq('user')
      expect(json['email']).to eq('user@gmail.com')
    end
  end
end
