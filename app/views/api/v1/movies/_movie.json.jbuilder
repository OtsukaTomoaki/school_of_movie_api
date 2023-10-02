json.id movie.id
json.title movie.title
json.overview movie.overview
json.vote_count movie.vote_count
json.vote_average movie.vote_average
json.poster_path movie.poster_path
json.backdrop_path movie.backdrop_path
json.original_language movie.original_language
json.release_date movie.release_date

json.movie_genres movie.movie_genre_relations.map { |relation|
  relation.movie_genre
}.sort_by { |movie_genre|
  movie_genre['the_movie_database_id']
} do |movie_genre|
  json.id movie_genre.id
  json.name movie_genre.name
end