class MacAuthenticationBypass < ApplicationRecord
  validates :address, presence: true, uniqueness: true

  audited
end
