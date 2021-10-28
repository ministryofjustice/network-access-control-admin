FactoryBot.define do
  factory :rule do
    policy

    sequence(:operator) { %w[equals contains].sample }
    sequence(:value) { |n| "Value #{n}" }
    sequence(:request_attribute) do
      %w[Framed-IP-Address
         Framed-IP-Netmask
         Framed-Routing].sample
    end
  end
end
