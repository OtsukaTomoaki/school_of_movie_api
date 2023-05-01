class AddArgumentsToBackgroundJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :background_jobs, :arguments, :json
    # もし、既存のインデックスが不要であれば、以下の行をコメントアウトしてください
    # remove_index :background_jobs, column: [:job_type, :query], unique: true
    add_index :background_jobs, :job_type
  end
end
