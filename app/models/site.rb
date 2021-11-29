class Site < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :clients, dependent: :destroy
  has_many :mac_authentication_bypasses, dependent: :nullify
  has_many :site_policy
  has_many :policies, through: :site_policy, dependent: :destroy

  before_save :generate_tag
  after_create :create_fallback_policy

  audited

  def fallback_policy
    policies.where(fallback: true).first
  end

private

  def generate_tag
    self.tag = name.parameterize(separator: "_")
  end

  def create_fallback_policy
    fallback_policy =
      Policy.new(
        name: "Fallback policy for #{name}",
        description: "Default fallback policy for #{name}",
        fallback: true,
      )
    if fallback_policy.save
      policies << fallback_policy
    else
      errors.add :name, "Failed to generate fallback policy with error: #{fallback_policy.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid
    end
  end
end
