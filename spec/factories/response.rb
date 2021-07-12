FactoryBot.define do
  factory :response do
    policy

    sequence(:response_attribute) { |n| "Response attribute #{n}" }
    sequence(:value) { |n| "Response value #{n}" }
  end
end
