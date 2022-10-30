class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.string :activation_digest
      t.boolean :activated, default: false
      t.datetime :activated_at
      t.string :remember_digest
    end

    add_index :users, :email, unique: true
  end
end
