class Api::V1::TalkRoomsController < ApplicationController
  def index
    @talk_rooms = TalkRoom
                    .left_joins(:talk_room_permissions)
                    .where(status: TalkRoom.statuses['release'])
                    .or(TalkRoomPermission.where(user_id: current_user.id))
                    .order(created_at: :DESC)
  end

  def create
    @talk_room = TalkRoomService.new.create!(form: talk_room_params, owner_user: current_user)
  end

  private
    def talk_room_params
      params.require(:talk_room).permit(:name, :describe, :status)
    end
end
