FactoryBot.define do
  factory :rule do
    policy
    request_attribute

    sequence(:operator) { ["equals", "contains"].sample }
    sequence(:value) { |n| "Value #{n}" }
  end
end
