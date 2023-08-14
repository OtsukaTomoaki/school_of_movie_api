class MovieUserLikes < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_user_likes, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :user_id, limit: 36, null: false, comment: 'ユーザーID'
      t.string :movie_id, limit: 36, null: false, comment: '映画ID'
      t.timestamps
    end

    add_index :movie_user_likes, [:user_id, :movie_id], unique: true
    add_index :movie_user_likes, [:user_id], unique: false
    add_index :movie_user_likes, [:movie_id], unique: false
  end
end
