class CreateSocialAccountMappings < ActiveRecord::Migration[7.0]
  def change
    create_table :social_account_mappings, id: false  do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.integer :social_id, null: false, comment: 'SNSのID'
      t.string :email, null: false
      t.string :social_account_id, null: false, comment: '連携するSNSのユーザID'
    end

    add_index :social_account_mappings, [:social_id, :email], unique: true
  end
end
