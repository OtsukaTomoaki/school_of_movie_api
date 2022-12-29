require 'rails_helper'

RSpec.describe "Api::V1::UserTags", type: :request, authentication: :skip  do
  describe 'index' do

    let!(:user_tags) {
      tag_1 = FactoryBot.create(:user_tag,
        user_id: authenticated_user.id,
        tag: 'foobar'
      )
      tag_2 = FactoryBot.create(:user_tag,
        user_id: authenticated_user.id,
        tag: 'hoge_fuga_PIYO'
      )
      user_tags = [
        {
          id: tag_1.id,
          user_id: tag_1.user_id,
          tag: tag_1.tag
        },
        {
          id: tag_2.id,
          user_id: tag_2.user_id,
          tag: tag_2.tag
        }
      ]

      user_tags.sort_by! { |tag| tag[:id] }
      {
        user_tags: user_tags
      }
    }
    let!(:body) {
      JSON.parse(user_tags.to_json)
    }
    it 'タグの一覧が取得できること' do
      get '/api/v1/user_tags'

      expect(response).to have_http_status 200
      json = JSON.parse(response.body)

      expect(json).to eq body
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
