class RoomChannel < ApplicationCable::Channel
  def subscribed
    raise Exception if TalkRoom.get(id: params[:id], user: current_user).blank?
    stream_from "room_channel_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Message.new(
      talk_room_id: params[:id],
      user_id: current_user.id,
      content: data['message']
    )
    if message.valid?
      message.save!
      ActionCable.server.broadcast("room_channel_#{params[:id]}", {message: message})
    end
  end

  def show
  end
end
