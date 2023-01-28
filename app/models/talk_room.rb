class TalkRoom < ApplicationRecord
  has_many :talk_room_permissions, dependent: :destroy
  validates :name, presence: true
  enum :status, { draft: 1, unlisted: 2, release: 3 }

  class << TalkRoom
    def get(id:, user:)
      TalkRoom.left_joins(:talk_room_permissions)
      .where(id: id)
      .merge(
        TalkRoom.left_joins(:talk_room_permissions)
          .where.not(status: TalkRoom.statuses['draft'])
          .or(TalkRoomPermission.where(
            user_id: user.id,
            owner: true
            )
          )
      ).first
    end
  end
end