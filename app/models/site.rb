class Site < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :clients, dependent: :destroy
  has_many :site_policy
  has_many :policies, through: :site_policy

  audited

  def fallback_policy
    @fallback_policy ||= policies.where(fallback: true).first
  end

  def tag
    name.parameterize(separator: "_")
  end
end
