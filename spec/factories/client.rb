FactoryBot.define do
  factory :client do
    site

    sequence(:shared_secret) { |n| "shared-secret-#{n}" }
    sequence(:ip_range) { |n| "127.0.0.#{n}/32" }
    radsec { false }
  end
end
