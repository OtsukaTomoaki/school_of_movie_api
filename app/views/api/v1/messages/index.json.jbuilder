json.messages do
  json.array!(@messages) do |message|
    json.partial! partial: 'api/v1/messages/message', locals: { message: message }
  end
end
