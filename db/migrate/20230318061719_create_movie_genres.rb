class CreateMovieGenres < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_genres, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :the_movie_database_id, limit: 36, null: false, comment: 'tmdbで管理されているid'
      t.string :name, limit: 100, null: false, comment: 'ジャンル名'
      t.timestamps
    end

    add_index :movie_genres, [:the_movie_database_id], unique: true
  end
end
