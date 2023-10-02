json.user_tags do
  json.array!(@user_tags) do |user_tag|
    json.partial! partial: 'api/v1/user_tags/user_tag', locals: { user_tag: user_tag }
  end
end