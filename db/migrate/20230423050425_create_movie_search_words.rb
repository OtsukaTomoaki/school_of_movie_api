class CreateMovieSearchWords < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_search_words, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :word

      t.timestamps
    end

    add_index :movie_search_words, :word
  end
end
