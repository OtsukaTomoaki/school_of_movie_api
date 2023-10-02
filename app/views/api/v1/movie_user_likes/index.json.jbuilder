json.movie_user_likes do
  json.array! @movie_user_likes do |movie_user_like|
    json.partial! partial: 'api/v1/movie_user_likes/movie_user_like', locals: { movie_user_like: movie_user_like }
  end
end
