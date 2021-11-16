class Site < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :clients, dependent: :destroy
  has_many :site_policy
  has_many :policies, through: :site_policy

  before_save :generate_tag
  after_create :create_fallback_policy
  after_destroy :destroy_fallback_policy

  audited

  def fallback_policy
    policies.where(fallback: true).first
  end

private

  def generate_tag
    self.tag = name.parameterize(separator: "_")
  end

  def create_fallback_policy
    policies << Policy.create!(
      name: name,
      description: "Default fallback policy for #{name}",
      fallback: true,
    )
  end

  def destroy_fallback_policy
    fallback_policy_id = fallback_policy.id

    site_policy.where(site_id: id, policy_id: fallback_policy_id).destroy_all
    Policy.find(fallback_policy_id).destroy
  end
end
