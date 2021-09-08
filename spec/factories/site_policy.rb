FactoryBot.define do
  factory :site_policy do
    site_id { FactoryBot.create(:site).id }
    policy_id { FactoryBot.create(:policy).id }
  end
end
