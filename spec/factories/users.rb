FactoryBot.define do
  require 'faker'

  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8)}
    password_digest { 'hoge' }
    activation_digest { 'hoge' }
    activated { true }
  end
end