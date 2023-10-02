class CreateBackgroundJobs < ActiveRecord::Migration[7.0]
  def change
    create_table :background_jobs, id: false  do |t|
      t.string :id, limit: 36, null: false, primary_key: true
      t.integer :job_type
      t.string :query
      t.integer :status
      t.integer :external_api_limit
      t.integer :external_api_requests_count, default: 0
      t.datetime :next_request_at
      t.timestamps
    end

    add_index :background_jobs, [:job_type, :query]
  end
end
