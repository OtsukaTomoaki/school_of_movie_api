class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    ActionCable.server.broadcast("room_channel_#{params[:id]}", {message: data['message']})
  end

  def show
  end
end
