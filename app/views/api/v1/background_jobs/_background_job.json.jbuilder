json.background_job do
  json.id background_job.id
  json.status background_job.status
  json.progress background_job.progress
  json.total background_job.total
  json.created_at background_job.created_at
  json.finished_at background_job.finished_at
  json.job_type background_job.job_type
  json.arguments background_job.arguments
end