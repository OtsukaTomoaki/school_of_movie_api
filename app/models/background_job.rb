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
  after_update :update_finished_at, if: :status_finished?

  def enqueue
    BackgroundJobWorker.perform_at(next_request_at, id)
  end

  def update_progress(new_progress, new_total: nil)
    if new_progress.present? && new_progress != progress
      self.progress = new_progress
    end
    if new_total.present? && new_total != total
      self.total = new_total
    end
    save!
  end

  class << self
    def search(status: nil, job_type: nil, page: 1, per: 10)
      query = self
      if status.present?
        query = query.where(status: status)
      end
      if job_type.present?
        query = query.where(job_type: job_type)
      end
      query.order(created_at: :desc).page(page).per(per)
    end

    def schedule_import_searched_movies(query:)
      # 検索結果の映画情報をインポートするジョブをスケジュールする
      arguments = { query: query }
      job_type = job_types[:import_searched_movies]

      already_scheduled_job = get_already_scheduled_background_job_in_progress(
        job_type: job_type,
        arguments: arguments
      )

      if already_scheduled_job.present?
        # すでに同じジョブが実行中の場合は、そのジョブを返す
        return already_scheduled_job
      end

      schedule_and_execute_job(
        job_type: job_type,
        next_request_at: Time.current,
        arguments: arguments
      )
    end

    private

    def get_already_scheduled_background_job_in_progress(job_type:, arguments:)
      BackgroundJob.where(
        job_type: job_type,
        status: [self.statuses[:pending], self.statuses[:processing]]
      ).where(
        "JSON_CONTAINS(arguments, ?)", arguments.to_json
      ).first
    end

    # ジョブをスケジュールし、BackgroundJobWorker によって実行させるメソッド
    def schedule_and_execute_job(job_type:, next_request_at:, arguments: {})
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

  private

  def status_finished?
    (status == 'complete' || status == 'error') && finished_at.blank?
  end

  def update_finished_at
    update(finished_at: Time.current)
  end
end
