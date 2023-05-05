class BackgroundJobWorker < ApplicationJobWorker
  sidekiq_options retry: 0
  def perform(job_id)

    job = BackgroundJob.find(job_id)
    job.processing!
    begin
      execute(job: job)
      job.complete!
    rescue => e
      job.error!
      raise e
    end
  end

  def execute(job:)
    parsed_arguments_to_deep_symbols = parse_arguments_to_deep_symbols(job.arguments)

    case job.job_type.to_sym
    when :import_searched_movies
      # 検索結果の映画情報をインポートする処理
      MovieService.import_searched_movies(**parsed_arguments_to_deep_symbols, job: job)
    else
      raise "Unsupported job_type: #{job_type}"
    end
  end
end