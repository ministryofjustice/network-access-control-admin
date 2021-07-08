FactoryBot.define do
  factory :request_attribute do
    sequence(:key) { |n| "Key #{n}" }
  end
end
