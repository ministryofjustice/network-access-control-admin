FactoryBot.define do
  factory :client do
    site

    sequence(:tag) { |n| "Client #{n}" }
    sequence(:shared_secret) { |n| "shared-secret-#{n}" }
    sequence(:ip_range) { |n| "127.0.0.#{n}" }
  end
end
