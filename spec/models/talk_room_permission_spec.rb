require 'rails_helper'

RSpec.describe TalkRoomPermission, type: :model do
  include_context 'create_talk_room'
  include_context 'create_user'

  shared_examples '権限に関わらずtalk_roomが取得できること' do
    let!(:talk_room_id) { talk_room.id }
    context '権限なしの場合' do
      it 'idが一致したtalk_roomが取得できること' do
        expect(subject).to eq talk_room
      end
    end
    context 'オーナー権限の場合' do
      before {
        FactoryBot.create(:talk_room_permission,
          talk_room_id: talk_room_id,
          user_id: user.id,
          owner: true,
        )
      }
      it 'idが一致したtalk_roomが取得できること' do
        expect(subject).to eq talk_room
      end
    end
    context '削除権限ありの場合' do
      before {
        FactoryBot.create(:talk_room_permission,
          talk_room_id: talk_room_id,
          user_id: user.id,
          allow_delete: true,
        )
      }
      it 'idが一致したtalk_roomが取得できること' do
        expect(subject).to eq talk_room
      end
    end
    context '編集権限ありの場合' do
      before {
        FactoryBot.create(:talk_room_permission,
          talk_room_id: talk_room_id,
          user_id: user.id,
          allow_edit: true,
        )
      }
      it 'idが一致したtalk_roomが取得できること' do
        expect(subject).to eq talk_room
      end
    end
  end


  describe "get" do
    subject {
      TalkRoom.get(id: talk_room_id, user: user)
    }
    context '下書き状態のtalk_roomの取得' do
      let!(:talk_room_id) { talk_room_draft.id }
      let!(:user) { user_1 }
      context 'talk_room_permissionが存在しないtalk_roomの取得' do
        it 'nilが返されること' do
          expect(subject).to eq nil
        end
      end
      context 'talk_room_permissionが存在するtalk_roomの取得' do
        context 'オーナー権限の場合' do
          before {
            FactoryBot.create(:talk_room_permission,
              talk_room_id: talk_room_id,
              user_id: user.id,
              owner: true,
            )
          }
          it 'idが一致しているtalk_toomが返されること' do
            expect(subject).to eq talk_room_draft
          end
        end
        context '削除権限ありの場合' do
          before {
            FactoryBot.create(:talk_room_permission,
              talk_room_id: talk_room_id,
              user_id: user.id,
              allow_delete: true,
            )
          }
          it 'nilが返されること' do
            expect(subject).to eq nil
          end
        end
        context '編集権限ありの場合' do
          before {
            FactoryBot.create(:talk_room_permission,
              talk_room_id: talk_room_id,
              user_id: user.id,
              allow_edit: true,
            )
          }
          it 'nilが返されること' do
            expect(subject).to eq nil
          end
        end
      end
    end

    context '下書き状態のtalk_roomの取得' do
      let!(:talk_room) { talk_room_unlisted }
      let!(:user) { user_1 }
      it_behaves_like '権限に関わらずtalk_roomが取得できること'
    end

    context '公開状態のtalk_roomの取得' do
      let!(:talk_room) { talk_room_release }
      let!(:user) { user_1 }
      it_behaves_like '権限に関わらずtalk_roomが取得できること'
    end
  end
end