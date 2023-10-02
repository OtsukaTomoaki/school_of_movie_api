class CreateTalkRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :talk_rooms, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.text :name, null: false
      t.text :describe, null: false, comment: '説明'
      t.integer :status, null: false, comment: 'トークルームのステータス（非公開, 限定公開, 公開）'
      t.datetime :created_at, null: true
      t.datetime :updated_at, null: true
    end
  end
end
