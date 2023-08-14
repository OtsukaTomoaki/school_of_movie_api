FactoryBot.define do
  require 'faker'

  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8)}
    activated { true }
  end
end