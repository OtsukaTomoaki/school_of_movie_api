json.id(@user.id)
json.name(@user.name)
json.email(@user.email)
json.tags do
  json.array!(@user.user_tags) do |tag|
    json.partial! partial: 'tags', locals: { tag: tag }
  end
end