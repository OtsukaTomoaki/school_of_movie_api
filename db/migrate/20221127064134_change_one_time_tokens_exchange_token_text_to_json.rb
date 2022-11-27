class ChangeOneTimeTokensExchangeTokenTextToJson < ActiveRecord::Migration[7.0]
  def change
    remove_column :one_time_tokens, :exchange_json
    add_column :one_time_tokens, :exchange_json, :json
  end
end
