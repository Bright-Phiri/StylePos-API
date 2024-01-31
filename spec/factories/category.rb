# frozen_string_literal: true

FactoryBot.define do
  factory :category do
    name { Faker::Name.name.split.first }
    description { Faker::Lorem.unique.sentence }
  end
end
