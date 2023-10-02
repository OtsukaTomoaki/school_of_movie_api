class AddMessageProgressAndTotalToBackgroundJobs < ActiveRecord::Migration[7.0]
  def change
    add_column :background_jobs, :message, :text
    add_column :background_jobs, :progress, :integer
    add_column :background_jobs, :total, :integer
    add_column :background_jobs, :finished_at, :datetime
  end
end
