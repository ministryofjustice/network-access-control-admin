# frozen_string_literal: true

FactoryBot.define do
  factory :site do
    sequence(:name) { |n| "Site #{n}" }
  end
end
