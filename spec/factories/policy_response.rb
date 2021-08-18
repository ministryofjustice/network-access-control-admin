FactoryBot.define do
  factory :policy_response do
    policy

    sequence(:response_attribute) { |n| "PolicyResponse attribute #{n}" }
    sequence(:value) { |n| "PolicyResponse value #{n}" }
  end
end
