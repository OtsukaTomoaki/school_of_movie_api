class Api::V1::TalkRoomsController < Api::V1::ApplicationController
  def index
    @talk_rooms = TalkRoom
                    .left_joins(:talk_room_permissions)
                    .where(status: TalkRoom.statuses['release'])
                    .or(TalkRoomPermission.where(user_id: current_user.id))
                    .order(created_at: :DESC)
  end

  def create
    @form = TalkRooms::Form.new(talk_room_params)
    if @form.valid?
      @talk_room = TalkRoomService.new.create!(form: @form, owner_user: current_user)
    else
      response_bad_request(errors: @form.error_messages)
    end
  end

  private
    def talk_room_params
      params.require(:talk_room).permit(:name, :describe, :status)
    end
end