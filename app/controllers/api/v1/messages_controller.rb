class Api::V1::MessagesController < Api::V1::ApplicationController
  def index
    talk_room = TalkRoom.get(id: params[:talk_room_id], user: current_user)
    if talk_room.present?
      @messages = Message.where(talk_room_id: talk_room.id).order(:created_at)
    else
      response_not_found
    end
  end
end
