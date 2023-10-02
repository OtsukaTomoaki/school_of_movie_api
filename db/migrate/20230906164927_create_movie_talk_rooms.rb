class CreateMovieTalkRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :movie_talk_rooms, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :movie_id, limit: 36, null: false, comment: '映画ID'
      t.string :talk_room_id, limit: 36, null: false, comment: 'トークルームID'
      t.timestamps
    end

    add_index :movie_talk_rooms, [:movie_id, :talk_room_id], unique: true
  end
end
