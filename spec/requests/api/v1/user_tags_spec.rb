require 'rails_helper'

RSpec.describe "Api::V1::UserTags", type: :request, authentication: :skip  do
  let!(:user_tags) {
    tag_1 = FactoryBot.create(:user_tag,
      user_id: authenticated_user.id,
      tag: 'foo_bar_バズ'
    )
    tag_2 = FactoryBot.create(:user_tag,
      user_id: authenticated_user.id,
      tag: 'hoge_fuga_PIYO'
    )
    tag_3 = FactoryBot.create(:user_tag,
      user_id: authenticated_user.id,
      tag: '!テスト試験テスト!'
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
      },
      {
        id: tag_3.id,
        user_id: tag_3.user_id,
        tag: tag_3.tag
      }
    ]

    user_tags.sort_by! { |tag| tag[:id] }
    {
      user_tags: user_tags
    }
  }
  describe 'index' do
    let!(:body) {
      JSON.parse(user_tags.to_json)
    }
    context '全件取得する場合' do
      it 'タグの一覧が取得できること' do
        get '/api/v1/user_tags'

        expect(response).to have_http_status 200
        json = JSON.parse(response.body)
        expect(json).to eq body
      end
      context '検索条件が指定されている場合' do
        subject {
          get "/api/v1/user_tags?q=#{search_word}"
        }
        context '前方部分一致の場合' do
          let!(:search_word) { URI.encode_www_form_component('foo') }
          it '1件取得できること' do
            subject
            expect(response).to have_http_status 200
            json = JSON.parse(response.body)

            res_user_tags = json['user_tags']
            expect(res_user_tags.length).to eq 1
            expect(res_user_tags.first['tag']).to eq 'foo_bar_バズ'
          end
        end
        context '中間部分一致の場合' do
          let!(:search_word) { URI.encode_www_form_component('_fuga') }
          it '1件取得できること' do
            subject
            expect(response).to have_http_status 200
            json = JSON.parse(response.body)

            res_user_tags = json['user_tags']
            expect(res_user_tags.length).to eq 1
            expect(res_user_tags.first['tag']).to eq 'hoge_fuga_PIYO'
          end
        end
        context '後方部分一致の場合' do
          let!(:search_word) { URI.encode_www_form_component('テスト!') }

          it '1件取得できること' do
            subject
            expect(response).to have_http_status 200
            json = JSON.parse(response.body)

            res_user_tags = json['user_tags']
            expect(res_user_tags.length).to eq 1
            expect(res_user_tags.first['tag']).to eq '!テスト試験テスト!'
          end
        end
      end
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

  describe 'delete' do
    let!(:user_tag_id) {
      user_tag = FactoryBot.create(:user_tag,
        user_id: authenticated_user.id,
        tag: '削除されるタグ'
      ).id
    }

    context 'タグの削除' do
      subject {
        delete "/api/v1/user_tags/#{user_tag_id}"
      }
      it 'タグが削除されていること' do
        expect { subject }.to change { UserTag.count }.by(-1)
        expect(response).to have_http_status 200

        json = JSON.parse(response.body)
        expect(json['id']).to eq user_tag_id
        expect(UserTag.find_by_id(json['id'])).to eq nil
      end
    end
  end
end
