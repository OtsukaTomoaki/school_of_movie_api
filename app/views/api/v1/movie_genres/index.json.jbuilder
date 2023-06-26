json.movie_genres do
  json.array!(@movie_genres) do |movie_genre|
    json.partial! partial: 'api/v1/movie_genres/movie_genre', locals: { movie_genre: movie_genre }
  end
end
