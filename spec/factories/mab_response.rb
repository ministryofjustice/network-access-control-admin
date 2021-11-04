FactoryBot.define do
  factory :mab_response do
    mac_authentication_bypass

    response_attribute { "Tunnel-Type" }
    value { "VLAN" }
  end
end
