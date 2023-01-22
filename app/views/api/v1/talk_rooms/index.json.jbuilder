json.talk_rooms do
  json.array!(@talk_rooms) do |talk_room|
    json.partial! partial: 'api/v1/talk_rooms/talk_room', locals: { talk_room: talk_room }
  end
end
