FactoryBot.define do
  factory :mac_authentication_bypass do
    sequence(:address) { |n| "aa-11-22-33-44-#{n}#{n}" }
    sequence(:name) { |n| "Printer #{n}" }
    sequence(:description) { |n| "Printer description #{n}" }
  end
end
