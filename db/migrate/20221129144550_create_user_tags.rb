class CreateUserTags < ActiveRecord::Migration[7.0]
  def change
    create_table :user_tags, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :user_id, limit: 36, null: false
      t.text :tag, limit: 60, null: false
    end
  end
end
