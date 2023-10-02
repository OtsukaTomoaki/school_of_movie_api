FactoryBot.define do
  require 'faker'

  factory :movie_genre do
    the_movie_database_id { Faker::Number.number(digits: 6) }
    name { "ジャンル_" }
  end
end
