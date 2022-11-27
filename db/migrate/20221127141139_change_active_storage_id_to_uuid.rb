class ChangeActiveStorageIdToUuid < ActiveRecord::Migration[7.0]
  def change
    change_column :active_storage_attachments, :record_id, :string, limit: 36, null: false
  end
end
