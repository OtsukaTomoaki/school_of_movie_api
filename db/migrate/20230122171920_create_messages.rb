class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :talk_room_id, limit: 36, null: false
      t.string :user_id, limit: 36, null: false
      t.text :content, comment: 'メッセージ内容'
      t.datetime :created_at, null: true
      t.datetime :updated_at, null: true
    end

    add_index :messages, [:talk_room_id], unique: false
  end
end
