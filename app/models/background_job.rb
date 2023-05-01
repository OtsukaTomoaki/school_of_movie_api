class BackgroundJob < ApplicationRecord
  validates :job_type, presence: true
  validates :query, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending processing complete error] }
  validates :external_api_limit, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :external_api_requests_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # 任意のジョブタイプについて、新しいジョブを作成または既存のジョブを取得します。
  def self.find_or_create_job(job_type, query)
    job = find_by(job_type: job_type, query: query)

    unless job
      job = create!(
        job_type: job_type,
        query: query,
        status: "pending",
        external_api_limit: 10 # ここで一定期間内のリクエスト上限を設定できます
      )
    end

    job
  end
end