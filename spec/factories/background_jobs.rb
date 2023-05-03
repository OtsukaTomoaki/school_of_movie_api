FactoryBot.define do
  factory :background_job do
    job_type { "import_serched_movies" }
    status { "pending" }
    next_request_at { Time.current }
    arguments { { "query" => "検索クエリ" } }
    external_api_limit { 10 }
    external_api_requests_count { 0 }
  end
end