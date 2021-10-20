FactoryBot.define do
  factory :rule do
    policy

    sequence(:operator) { %w[equals contains].sample }
    sequence(:value) { |n| "Value #{n}" }
    sequence(:request_attribute) { AttributesHelper.requests.sample }
  end
end
