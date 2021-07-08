FactoryBot.define do
  factory :rule do
    policy

    sequence(:operator) { ["equals", "contains"].sample }
    sequence(:value) { |n| "Value #{n}" }
    sequence(:request_attribute) { |n| "Request attribute #{n}" }
  end
end
