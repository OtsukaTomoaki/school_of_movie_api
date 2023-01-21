require 'rails_helper'

RSpec.describe RoomChannel, authentication: :skip, type: :channel do
  before do
    stub_connection current_user: authenticated_user
  end

  describe "メッセージの送信" do
    let!(:speak_message) { 'サンプル_Sample' }
    let!(:channel_name) { 'room_channel' }

    it "チェンネルの接続ができること" do
      subscribe
      expect(subscription).to be_confirmed
    end

    it "メッセージを送信するとブロードキャストされたデータに含まれていること" do
      subscribe
      expect(subscription).to be_confirmed
      expect do
        perform :speak, message: speak_message
      end. to have_broadcasted_to(channel_name).with{ |data|
        expect(data['message']).to eq speak_message
      }
    end
  end
end
