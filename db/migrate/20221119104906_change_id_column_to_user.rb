class ChangeIdColumnToUser < ActiveRecord::Migration[7.0]
  #変更内容
  def up
    change_column :users, :id, :string, limit: 36, unique: true, auto_increment: false, null: false, primary_key: true
  end

  # 変更前の状態
  def down
    change_column :users, :id, :integer
  end

  execute <<~SQL
    ALTER TABLE `users` DROP PRIMARY KEY;
  SQL
end
