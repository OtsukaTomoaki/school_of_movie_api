class AddIndexMovieIdMovieTalkRoom < ActiveRecord::Migration[7.0]
  add_index :movie_talk_rooms, [:movie_id], unique: true
end
