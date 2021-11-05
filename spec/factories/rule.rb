FactoryBot.define do
  factory :rule do
    policy

    sequence(:operator) { %w[equals contains].sample }
    request_attribute { "Reply-Message" }
    value { "'Hello from NACS'" }
  end
end
