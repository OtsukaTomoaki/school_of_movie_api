class RemoveMovieUserLikesIdColumun < ActiveRecord::Migration[7.0]
  def change
    remove_column :movie_user_likes, :id, :string, limit: 36, null: false, primary_key: true
  end
end
