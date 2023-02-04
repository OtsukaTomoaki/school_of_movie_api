require 'rails_helper'

RSpec.describe RoomChannel, authentication: :skip, type: :channel do
  before do
    stub_connection current_user: authenticated_user
  end

  describe "メッセージの送信" do
    let!(:talk_room_id) {
      FactoryBot.create(
        :talk_room,
        name: 'sample_talk_rooms',
        describe: 'wawawa!',
        status: TalkRoom.statuses['release']
      ).id
    }
    let!(:speak_message) { 'サンプル_Sample' }
    let!(:channel_name) { "room_channel_#{talk_room_id}" }

    it "チェンネルの接続ができること" do
      subscribe id: talk_room_id
      expect(subscription).to be_confirmed
    end

    let(:expect_message) {
        Message
          .where(talk_room_id: talk_room_id)
          .order(created_at: 'DESC')
          .first
    }
    it "メッセージを送信するとブロードキャストされたデータに含まれていること" do
      subscribe id: talk_room_id
      expect(subscription).to be_confirmed
      expect do
        perform :speak, message: speak_message
      end. to have_broadcasted_to(channel_name).with{ |data|
        response_message = data['message']
        expect(response_message['id']).to eq expect_message.id
        expect(response_message['talk_room_id']).to eq expect_message.talk_room_id
        expect(response_message['user']['id']).to eq authenticated_user.id
        expect(response_message['user']['name']).to eq authenticated_user.name
        expect(response_message['content']).to eq expect_message.content
        expect(response_message['created_at']).to eq expect_message.created_at.iso8601(3)
      }
    end
  end
end
