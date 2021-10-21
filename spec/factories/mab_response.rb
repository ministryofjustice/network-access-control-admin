FactoryBot.define do
  factory :mab_response do
    mac_authentication_bypass

    sequence(:response_attribute) { AttributesHelper.responses.sample }
    sequence(:value) { |n| "MAB Response value #{n}" }
  end
end
