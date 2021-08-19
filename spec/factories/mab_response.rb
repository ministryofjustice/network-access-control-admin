FactoryBot.define do
  factory :mab_response do
    mac_authentication_bypass

    sequence(:response_attribute) { |n| "MAB Response attribute #{n}" }
    sequence(:value) { |n| "MAB Response value #{n}" }
  end
end
