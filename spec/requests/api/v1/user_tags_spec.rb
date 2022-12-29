require 'rails_helper'

RSpec.describe "Api::V1::UserTags", type: :request, authentication: :skip  do
  describe 'index' do
    it 'タグの一覧が取得できること' do
      get '/api/v1/user_tags'

      expect(response).to have_http_status 200
    end
  end
  describe 'post' do
    let!(:tags) {
      tag = {
        tag: "sample!!!!!!!"
      }
    }
    context 'タグの新規追加' do
      it 'タグが登録されていること' do
        post '/api/v1/user_tags', params: tags

        expect(response).to have_http_status 200
        json = JSON.parse(response.body)
        expect(json['tag']).to eq 'sample!!!!!!!'
      end
    end
  end
end
