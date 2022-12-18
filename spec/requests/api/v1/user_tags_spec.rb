require 'rails_helper'

RSpec.describe "Api::V1::UserTags", type: :request, authentication: :skip  do
  context 'タグ追加処理の検証' do
    let!(:tags) {
      tag = {
        tag: "うわぁぁぁぁぁ!!!!!!!"
      }
    }
    it 'タグを追加できる' do
      post '/api/v1/user_tags', params: tags

      expect(response).to have_http_status 200
      json = JSON.parse(response.body)
      expect(json['tag']).to eq 'うわぁぁぁぁぁ!!!!!!!'
    end
  end
end
