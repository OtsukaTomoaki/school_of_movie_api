class CreateTalkRoomPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :talk_room_permissions, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :talk_room_id, limit: 36, null: false
      t.string :user_id, limit: 36, null: false
      t.boolean :owner, default: false, comment: 'トークルームのオーナー権限（オーナー、変更、削除権限を変更できる）'
      t.boolean :allow_edit, default: false, comment: 'トークルームの変更権限'
      t.boolean :allow_delete, default: false, comment: 'トークルームの削除権限'
      t.datetime :created_at, null: true
      t.datetime :updated_at, null: true
    end

    add_index :talk_room_permissions, [:talk_room_id, :user_id], unique: true
  end
end
