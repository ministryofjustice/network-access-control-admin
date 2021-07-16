FactoryBot.define do
  factory :certificate do
    sequence(:name) { |n| "Certificate #{n}" }
    sequence(:description) { |n| "Certificate description #{n}" }
    sequence(:expiry_date) { Date.today }
    sequence(:subject) { |n| "Certificate subject #{n}" }
  end
end
