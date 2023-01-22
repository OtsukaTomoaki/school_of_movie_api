class TalkRoomService
  include CustomException

  def create!(form:, owner_user:)
    ActiveRecord::Base.transaction do
      talk_room = TalkRoom.create!(form.attributes)

      TalkRoomPermission.create!(
        talk_room_id: talk_room.id,
        user_id: owner_user.id,
        owner: true,
        allow_edit: true,
        allow_delete: true,
      )
      talk_room
    end
  end
end