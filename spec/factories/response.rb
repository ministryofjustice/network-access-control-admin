FactoryBot.define do
  factory :response do
    response_attribute { "Reply-Message" }
    value { "'Hello from NACS'" }
  end
end
