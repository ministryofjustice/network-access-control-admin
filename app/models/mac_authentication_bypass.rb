class MacAuthenticationBypass < ApplicationRecord
  belongs_to :site

  paginates_per 50

  validates :address, :name, :description, :site_id, presence: true
  validates :address, uniqueness: true, unless: :skip_uniqueness_validation?
  validates_format_of :address, with: /\A([0-9a-f]{2}-){5}([0-9a-f]{2})\z/, on: :create, if: -> { address.present? }

  has_many :responses, dependent: :destroy

  audited

  def self.ransackable_attributes(_auth_object = nil)
    ["address", "created_at", "description", "id", "name", "site_id", "updated_at"]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["audits", "responses", "site"]
  end

  def skip_uniqueness_validation?
    false
  end
end
