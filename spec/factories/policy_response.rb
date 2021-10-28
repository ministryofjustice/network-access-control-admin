FactoryBot.define do
  factory :policy_response do
    policy

    sequence(:response_attribute) do
      %w[Port-Limit
         Proxy-State
         Reply-Message].sample
    end
    sequence(:value) { |n| "PolicyResponse value #{n}" }
  end
end
