class BackgroundJob < ApplicationRecord
  enum job_type: {
    import_searched_movies: 20,
    # ... その他のジョブタイプ
  }

  enum status: {
    pending: 10,
    processing: 20,
    complete: 30,
    error: 40,
  }

  validates :job_type, presence: true
  validates :next_request_at, presence: true

  def enqueue
    BackgroundJobWorker.perform_at(next_request_at, id)
  end

  class << self
    def schedule_import_searched_movies(query:)
      # 検索結果の映画情報をインポートするジョブをスケジュールする
      schedule_and_execute_job(
        job_type: job_types[:import_searched_movies],
        next_request_at: Time.current,
        arguments: { query: query }
      )
    end
  end

  private

  # ジョブをスケジュールし、BackgroundJobWorker によって実行させるメソッド
  def self.schedule_and_execute_job(job_type:, next_request_at:, arguments: {})
    # トランザクションをはる
    job = new(
      job_type: job_type,
      status: :pending,
      next_request_at: next_request_at,
      arguments: arguments
    )
    ActiveRecord::Base.transaction do
      job.save!
      BackgroundJobWorker.perform_at(next_request_at, job.id)
    end
    job
  end
end
