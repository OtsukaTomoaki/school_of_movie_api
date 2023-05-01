FactoryBot.define do
  factory :background_job do
    job_type { "movie_search" }
    query { "Inception" }
    status { "pending" }
    external_api_limit { 10 }
    external_api_requests_count { 0 }
  end
end