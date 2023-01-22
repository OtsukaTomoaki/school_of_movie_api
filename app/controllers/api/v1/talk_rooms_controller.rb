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

  def update
    @form = TalkRooms::Form.new(talk_room_params)
    if @form.valid?
      talk_room_service = TalkRoomService.new
      unless @talk_room = talk_room_service.update!(form: @form, user: current_user)
        response_bad_request(errors: talk_room_service.error_messages)
      end
    else
      response_bad_request(errors: @form.error_messages)
    end
  end

  def destroy
    @id = params[:id]
    talk_room_service = TalkRoomService.new
    result = talk_room_service.destroy!(id: @id, user: current_user)
    if !result
      response_bad_request(errors: talk_room_service.error_messages)
    end
  end

  private
    def talk_room_params
      @talk_room_params ||= params.require(:talk_room).permit(:name, :describe, :status)
      if params[:id]
        @talk_room_params.merge!(id: params[:id])
      end
      @talk_room_params
    end
end
