FactoryBot.define do
  factory :policies_sites do
    site_id { FactoryBot.create(:site).id }
    policy_id { FactoryBot.create(:policy).id }
  end
end
