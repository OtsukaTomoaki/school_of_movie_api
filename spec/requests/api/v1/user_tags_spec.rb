require 'rails_helper'

RSpec.describe "Api::V1::UserTags", type: :request, authentication: :skip  do
  describe 'post' do
    let!(:tags) {
      tag = {
        tag: "うわぁぁぁぁぁ!!!!!!!"
      }
    }
    context 'タグの新規追加' do
      it 'タグが登録されていること' do
        post '/api/v1/user_tags', params: tags

        expect(response).to have_http_status 200
        json = JSON.parse(response.body)
        expect(json['tag']).to eq 'うわぁぁぁぁぁ!!!!!!!'
      end
    end
  end
end
