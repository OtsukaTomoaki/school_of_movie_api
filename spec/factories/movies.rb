FactoryBot.define do
  require 'faker'

  factory :movie do
    the_movie_database_id { Faker::Number.number(digits: 6) }
    title { Faker::Movie.title }
    overview { Faker::Fantasy::Tolkien.poem  }
    original_title { Faker::Movie.quote }
    adult { (Faker::Number.number(digits: 1) % 2).zero? }
    release_date { Faker::Date.between(from: '1890-01-01', to: '2023-03-01') }
    poster_path { "/poster_path/#{Faker::Number.number(digits: 10)}.jpg" }
    backdrop_path { "/backdrop_path/#{Faker::Number.number(digits: 10)}.jpg" }
    original_language { (Faker::Number.number(digits: 1) % 2).zero? ? 'ja' : 'en' }
    vote_average { Faker::Number.decimal(l_digits: 3, r_digits: 3) }
    vote_count { Faker::Number.number(digits: 6) }
  end
end
