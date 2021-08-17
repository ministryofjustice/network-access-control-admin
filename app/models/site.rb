class Site < ApplicationRecord
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :clients, dependent: :destroy
  has_and_belongs_to_many :policies, -> { distinct }

  audited

  def fallback_policy
    @fallback_policy ||= policies.where(fallback: true).first
  end
end
