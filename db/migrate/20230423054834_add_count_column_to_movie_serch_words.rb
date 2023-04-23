class AddCountColumnToMovieSerchWords < ActiveRecord::Migration[7.0]
  def change
    add_column :movie_search_words, :count, :integer
  end
end
