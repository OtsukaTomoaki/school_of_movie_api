FactoryBot.define do
  require 'faker'
  factory :movie_search_word do
    word { Faker::Lorem.word }
    count { 0 }
  end
end