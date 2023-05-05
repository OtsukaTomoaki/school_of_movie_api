json.movies do
  json.array!(@movies) do |movie|
    json.partial! partial: 'api/v1/movies/movie', locals: { movie: movie }
  end
end
json.meta do
  if @background_job.present?
    json.partial! partial: 'api/v1/background_jobs/background_job', locals: { background_job: @background_job }
  else
    json.background_job nil
  end
end
