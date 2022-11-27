class CreateOneTimeTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :one_time_tokens, id: false do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.string :exchange_json
      t.datetime :expires_at
    end
  end
end
