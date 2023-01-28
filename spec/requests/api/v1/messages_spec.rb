require 'rails_helper'

RSpec.describe "Api::V1::Messages", type: :request, authentication: :skip do
  include_context 'create_talk_room'
  include_context 'create_user'

  describe "GET /index" do
    subject {
      get "/api/v1/messages?talk_room_id=#{talk_room_id}"
    }

    before {
        # メッセージの追加
        FactoryBot.create(:message,
          talk_room_id: talk_room_id,
          user_id: user_1.id,
          content: 'あいうえお',
        )
        FactoryBot.create(:message,
          talk_room_id: talk_room_id,
          user_id: user_2.id,
          content: 'かきくけこ',
        )
        FactoryBot.create(:message,
          talk_room_id: talk_room_id,
          user_id: user_3.id,
          content: 'さしすせそ',
        )

        # 別のトークルームのメッセージ
        FactoryBot.create(:message,
          talk_room_id: another_talk_room_id_1,
          user_id: user_1.id,
          content: 'wawawa!?',
        )
        FactoryBot.create(:message,
          talk_room_id: another_talk_room_id_2,
          user_id: user_1.id,
          content: 'hahaha!',
        )
    }

    shared_examples 'ステータスコード200とトークルーム内のメッセージの一覧が返されること' do
      it do
          subject
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['messages'].pluck('id')).to eq message_ids_on_db

          last_message = json['messages'].last
          expect(last_message['talk_room_id']).to eq talk_room_id
          expect(last_message['user_id']).to eq message_user_id
          expect(last_message['content']).to eq message_content
      end
    end
    shared_examples 'ステータスコード404が返されること' do
      it do
        subject
        expect(response).to have_http_status 404
      end
    end

    context "未公開のトークルームのメッセージを取得する場合" do
      let!(:talk_room_id) { talk_room_draft.id }
      let!(:another_talk_room_id_1) { talk_room_unlisted.id }
      let!(:another_talk_room_id_2) { talk_room_release.id }
      context "トークルームの所有者の場合" do
        before {
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_id,
            user_id: authenticated_user.id,
            owner: true,
          )
        }
        let!(:message_user_id) { user_3.id }
        let!(:message_content) { 'さしすせそ' }
        let!(:message_ids_on_db) {
          Message.where(talk_room_id: talk_room_id).order(:created_at).pluck(:id)
        }
        it_behaves_like 'ステータスコード200とトークルーム内のメッセージの一覧が返されること'
      end

      context "トークルームの所有者ではない場合" do
        it_behaves_like 'ステータスコード404が返されること'
      end
    end

    context "限定公開のトークルームのメッセージを取得する場合" do
      let!(:talk_room_id) { talk_room_unlisted.id }
      let!(:another_talk_room_id_1) { talk_room_draft.id }
      let!(:another_talk_room_id_2) { talk_room_release.id }
      let!(:message_user_id) { user_3.id }
      let!(:message_content) { 'さしすせそ' }
      let!(:message_ids_on_db) {
        Message.where(talk_room_id: talk_room_id).order(:created_at).pluck(:id)
      }
      context "トークルームの所有者の場合" do
        before {
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_id,
            user_id: authenticated_user.id,
            owner: true,
          )
        }
        it_behaves_like 'ステータスコード200とトークルーム内のメッセージの一覧が返されること'
      end

      context "トークルームの所有者ではない場合" do
        it_behaves_like 'ステータスコード200とトークルーム内のメッセージの一覧が返されること'
      end
    end

    context "公開済みのトークルームのメッセージを取得する場合" do
      let!(:talk_room_id) { talk_room_release.id }
      let!(:another_talk_room_id_1) { talk_room_draft.id }
      let!(:another_talk_room_id_2) { talk_room_unlisted.id }
      let!(:message_user_id) { user_3.id }
      let!(:message_content) { 'さしすせそ' }
      let!(:message_ids_on_db) {
        Message.where(talk_room_id: talk_room_id).order(:created_at).pluck(:id)
      }
      context "トークルームの所有者の場合" do
        before {
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_id,
            user_id: authenticated_user.id,
            owner: true,
          )
        }
        it_behaves_like 'ステータスコード200とトークルーム内のメッセージの一覧が返されること'
      end
      context "トークルームの所有者ではない場合" do
        it_behaves_like 'ステータスコード200とトークルーム内のメッセージの一覧が返されること'
      end
    end
  end
end
