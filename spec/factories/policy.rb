# frozen_string_literal: true

FactoryBot.define do
  factory :policy do
    sequence(:name) { |n| "Policy #{n}" }
    sequence(:description) { |n| "Policy description #{n}" }
  end
end
