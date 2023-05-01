class RemoveQueryFromBackgroundJobs < ActiveRecord::Migration[7.0]
  def change
    remove_column :background_jobs, :query, :string
  end
end
