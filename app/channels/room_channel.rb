class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Message.create!(
      talk_room_id: params[:id],
      user_id: current_user.id,
      content: data['message']
    )
    ActionCable.server.broadcast("room_channel_#{params[:id]}", {message: message})
  end

  def show
  end
end
