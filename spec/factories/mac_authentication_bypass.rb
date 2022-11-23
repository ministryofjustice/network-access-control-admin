FactoryBot.define do
  factory :mac_authentication_bypass do
    site_id { FactoryBot.create(:site).id }
    sequence(:address) { "aa-11-22-33-44-11" }
    sequence(:name) { |n| "Printer #{n}" }
    sequence(:description) { |n| "Printer description #{n}" }
  end
end
