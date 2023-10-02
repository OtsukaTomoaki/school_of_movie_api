class ChangeMoviesVoteAvarageColumn < ActiveRecord::Migration[7.0]
  def change
    change_column :movies, :vote_average, :decimal, precision: 11, scale: 8, null: true
  end
end
