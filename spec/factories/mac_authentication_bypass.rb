FactoryBot.define do
  factory :mac_authentication_bypass do
    sequence(:address) { |n| "00:11:22:33:4#{n}" }
    sequence(:name) { |n| "Printer #{n}" }
    sequence(:description) { |n| "Printer description #{n}" }
  end
end
