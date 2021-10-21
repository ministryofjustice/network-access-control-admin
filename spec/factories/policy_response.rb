FactoryBot.define do
  factory :policy_response do
    policy

    sequence(:response_attribute) { AttributesHelper.responses.sample }
    sequence(:value) { |n| "PolicyResponse value #{n}" }
  end
end
