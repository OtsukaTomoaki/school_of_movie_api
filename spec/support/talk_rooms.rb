RSpec.shared_context 'create_talk_room' do
  let!(:talk_room_draft) {
    FactoryBot.create(:talk_room,
      name: 'トークルームのタイトル_1',
      describe: '未公開のトークルーム',
      status: TalkRoom.statuses['draft']
    )
  }
  let!(:talk_room_unlisted) {
    FactoryBot.create(:talk_room,
      name: 'トークルームのタイトル_2',
      describe: '限定公開のトークルーム',
      status: TalkRoom.statuses['unlisted']
    )
  }
  let!(:talk_room_release) {
    FactoryBot.create(:talk_room,
      name: 'トークルームのタイトル_3',
      describe: '公開済みのトークルーム',
      status: TalkRoom.statuses['release']
    )
  }
end