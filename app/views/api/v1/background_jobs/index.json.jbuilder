json.background_jobs do
  json.array!(@background_jobs) do |background_job|
    json.partial! partial: 'api/v1/background_jobs/background_job', locals: { background_job: background_job }
  end
end
