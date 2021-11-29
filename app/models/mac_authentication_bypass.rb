class MacAuthenticationBypass < ApplicationRecord
  belongs_to :site, optional: true

  paginates_per 50

  validates :address, presence: true, uniqueness: true
  validates_format_of :address, with: /\A([0-9a-f]{2}-){5}([0-9a-f]{2})\z/, on: :create

  has_many :responses, dependent: :destroy

  audited
end
