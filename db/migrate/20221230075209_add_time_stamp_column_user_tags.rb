class AddTimeStampColumnUserTags < ActiveRecord::Migration[7.0]
  def up
    add_column :user_tags, :created_at, :datetime, null: true
  end

  def down
    remove_column :user_tags, :created_at
  end
end
