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

  def destroy!(id:, user:)
    if TalkRoomPermission.exists?(
      talk_room_id: id,
      user_id: user.id,
      allow_delete: true
    )
      ActiveRecord::Base.transaction do
        talk_room = TalkRoom.find_by_id(id)
        TalkRoomPermission.where(talk_room_id: talk_room.id).destroy_all
        talk_room.destroy!
        talk_room
      end
    else
      @error_messages = [
        '権限がありません'
      ]
      return false
    end
  end

  def error_messages
    @error_messages
  end
end