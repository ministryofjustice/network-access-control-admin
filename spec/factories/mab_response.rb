FactoryBot.define do
  factory :mab_response do
    mac_authentication_bypass

    sequence(:response_attribute) do
      %w[Port-Limit
         Proxy-State
         Reply-Message].sample
    end
    sequence(:value) { |n| "MAB Response value #{n}" }
  end
end
