require 'rails_helper'

RSpec.describe "Api::V1::TalkRooms", type: :request, authentication: :skip do
  RSpec::Matchers.define_negated_matcher :not_change, :change

  describe 'index' do
    before {
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_1',
        describe: '未公開のトークルーム',
        status: TalkRoom.statuses['draft']
      )
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_2',
        describe: '限定公開のトークルーム',
        status: TalkRoom.statuses['unlisted']
      )
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_3',
        describe: '公開中のトークルーム_3',
        status: TalkRoom.statuses['release']
      )
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_4',
        describe: '公開中のトークルーム_4',
        status: TalkRoom.statuses['release']
      )
    }
    subject {
      get '/api/v1/talk_rooms'
    }
    context '全件取得する場合' do
      it 'talk_roomsの一覧がcreated_atの降順で2件取得できること' do
        subject
        expect(response).to have_http_status 200
        json = JSON.parse(response.body)
        expect(json['talk_rooms'].pluck('name')).to eq [
          'トークルームのタイトル_4',
          'トークルームのタイトル_3',
        ]
      end
      context 'talk_room_permissionに認証ずみのユーザIDが存在する場合' do
        before {
          talk_room_5 = FactoryBot.create(:talk_room,
            name: 'トークルームのタイトル_5',
            describe: 'トークルームの説明',
            status: TalkRoom.statuses['draft']
          )
          talk_room_6 = FactoryBot.create(:talk_room,
            name: 'トークルームのタイトル_6',
            describe: 'トークルームの説明',
            status: TalkRoom.statuses['unlisted']
          )
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_5.id,
            user_id: authenticated_user.id,
            owner: true
          )
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_6.id,
            user_id: authenticated_user.id,
            owner: true
          )
        }
        it 'talk_roomsの一覧がcreated_atの降順で4件取得できること' do
          subject
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['talk_rooms'].pluck('name')).to eq [
            'トークルームのタイトル_6',
            'トークルームのタイトル_5',
            'トークルームのタイトル_4',
            'トークルームのタイトル_3'
          ]
        end
      end
    end
  end

  describe 'create' do
    let!(:params) {
      {
        talk_room: {
          name: name,
          describe: describe,
          status: status,
        }
      }
    }
    subject {
      post '/api/v1/talk_rooms', params: params, as: :json
    }
    context '正常系' do
      context 'name, describe, statusが指定されている場合' do
        let!(:name) {
          'foo'
        }
        let!(:describe) {
          'foo_bar_buz'
        }
        let!(:status) {
          TalkRoom.statuses['release']
        }
        it 'ステータスコード200が返されること' do
          subject
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['name']).to eq name
          expect(json['describe']).to eq describe
          expect(json['status']).to eq 'release'
        end
      end
      context 'describeが空の場合' do
        let!(:name) {
          'foo'
        }
        let!(:describe) {
          ''
        }
        let!(:status) {
          TalkRoom.statuses['release']
        }
        it 'ステータスコード200が返されること' do
          subject
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['name']).to eq name
          expect(json['describe']).to eq describe
          expect(json['status']).to eq 'release'
        end
      end
    end

    context '異常系' do
      context 'nameが空の場合' do
        let!(:name) {
          ''
        }
        let!(:describe) {
          'foo_bar_buz'
        }
        let!(:status) {
          TalkRoom.statuses['release']
        }
        let!(:error_message) {
          {
            "status"=>400,
            "errors"=>[
              {
                "attribute"=>"name",
                "message"=>"Name can't be blank"
              }
            ]
          }
        }
        it 'ステータスコード400が返されること' do
          subject
          expect(response).to have_http_status 400
          json = JSON.parse(response.body)
          expect(json).to eq error_message
        end
      end

      context 'statusが空の場合' do
        let!(:name) {
          'name'
        }
        let!(:describe) {
          'foo_bar_buz'
        }
        let!(:status) {
          nil
        }
        let!(:error_message) {
          {
            "status"=>400,
            "errors"=>[
              {
                "attribute"=>"status",
                "message"=>"Status can't be blank"
              }
            ]
          }
        }
        it 'ステータスコード400が返されること' do
          subject
          expect(response).to have_http_status 400
          json = JSON.parse(response.body)
          expect(json).to eq error_message
        end
      end
    end
  end

  describe 'destroy' do
    let!(:talk_room_1) {
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_1',
        describe: '未公開のトークルーム',
        status: TalkRoom.statuses['draft']
      )
    }
    let!(:talk_room_2) {
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_2',
        describe: '限定公開のトークルーム',
        status: TalkRoom.statuses['unlisted']
      )
    }

    let!(:talk_room_3) {
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_3',
        describe: '公開中のトークルーム_3',
        status: TalkRoom.statuses['release']
      )
    }

    let!(:talk_room_4) {
      FactoryBot.create(:talk_room,
        name: 'トークルームのタイトル_4',
        describe: '公開中のトークルーム_4',
        status: TalkRoom.statuses['release']
      )
    }
    subject {
      delete "/api/v1/talk_rooms/#{talk_room_id}"
    }

    context '正常系' do
      let!(:talk_room_id) { talk_room_1.id }
      context 'talk_roomの削除権限のみがある場合' do
        before {
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_1.id,
            user_id: authenticated_user.id,
            allow_delete: true,
          )
        }
        it 'ステータスコードが200でレスポンスされ、talk_roomが1件減っていること' do
          expect { subject }.to change { TalkRoom.count }.by(-1)
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['id']).to eq talk_room_id

          expect(TalkRoom.where(id: talk_room_1.id).count).to eq 0
          expect(TalkRoomPermission.where(talk_room_id: talk_room_1.id).count).to eq 0
        end
      end
      context 'talk_roomの全ての権限がある場合' do
        before {
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_1.id,
            user_id: authenticated_user.id,
            owner: true,
            allow_edit: true,
            allow_delete: true,
          )
        }
        it 'ステータスコードが200でレスポンスされ、talk_roomが1件減っていること' do
          expect { subject }.to change { TalkRoom.count }.by(-1)
          expect(response).to have_http_status 200
          json = JSON.parse(response.body)
          expect(json['id']).to eq talk_room_id

          expect(TalkRoom.where(id: talk_room_1.id).count).to eq 0
          expect(TalkRoomPermission.where(talk_room_id: talk_room_1.id).count).to eq 0
        end
      end
    end

    context '異常系' do
      let!(:talk_room_id) { talk_room_1.id }
      context 'talk_roomの削除権限がない場合' do
        before {
          FactoryBot.create(:talk_room_permission,
            talk_room_id: talk_room_1.id,
            user_id: authenticated_user.id,
            allow_delete: false,
          )
        }
        it 'ステータスコードが400でレスポンスされ、talk_roomが1件減っていること' do
          expect { subject }.to not_change { TalkRoom.count }
          expect(response).to have_http_status 400
          json = JSON.parse(response.body)
          expect(json['errors']).to eq ['権限がありません']
        end
      end
    end
  end
end
