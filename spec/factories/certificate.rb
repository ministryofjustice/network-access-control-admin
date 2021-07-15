FactoryBot.define do
  factory :certificate do
    sequence(:name) { |n| "Certificate #{n}" }
    sequence(:description) { |n| "Certificate description #{n}" }
    sequence(:expiry_date) { Date.today }
    sequence(:properties) { |n| "Certificate properties #{n}" }
  end
end
