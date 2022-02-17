FactoryBot.define do
  factory :certificate do
    sequence(:name) { |n| "Certificate #{n}" }
    sequence(:description) { |n| "Certificate description #{n}" }
    sequence(:expiry_date) { Date.today }
    sequence(:subject) { |n| "Certificate subject #{n}" }
    sequence(:issuer) { |n| "Certificate issuer #{n}" }
    sequence(:serial) { |n| "Certificate serial #{n}" }
    sequence(:extensions) { |n| "Certificate extensions #{n}" }
    sequence(:filename) { |n| "ca#{n}.pem" }
    certificate_type { :server }
    category { "EAP" }
  end
end
