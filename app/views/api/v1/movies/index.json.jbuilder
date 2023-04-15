json.movies do
  json.array!(@movies) do |movie|
    json.partial! partial: 'api/v1/movies/movie', locals: { movie: movie }
  end
end