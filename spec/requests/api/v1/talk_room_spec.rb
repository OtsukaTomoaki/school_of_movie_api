require 'rails_helper'

RSpec.describe "Api::V1::TalkRooms", type: :request, authentication: :skip do
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
    end
  end
end
