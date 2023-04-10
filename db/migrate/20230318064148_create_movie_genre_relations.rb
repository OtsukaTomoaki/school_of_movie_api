class CreateMovieGenreRelations < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_genre_relations, id: false do |t|
      t.string :movie_id, limit: 36, null: false, comment: '映画ID'
      t.string :movie_genre_id, limit: 36, null: false, comment: '映画ジャンルID'
    end

    add_index :movie_genre_relations, [:movie_id, :movie_genre_id], unique: true
  end
end
