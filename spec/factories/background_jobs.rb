FactoryBot.define do
  factory :background_job do
    job_type { 20 }
    status { 10 }
    next_request_at { Time.current }
    arguments { { "query" => "検索クエリ" } }
    external_api_limit { 10 }
    external_api_requests_count { 0 }
  end
end
