class ChangeOneTimeTokens < ActiveRecord::Migration[7.0]
  def change
    change_column :one_time_tokens, :exchange_token, :text
  end
end
