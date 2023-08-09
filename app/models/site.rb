class Site < ApplicationRecord
  paginates_per 50

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }, unless: :skip_uniqueness_validation?

  has_many :clients, dependent: :destroy
  has_many :mac_authentication_bypasses, dependent: :destroy
  has_many :site_policy
  has_many :policies, through: :site_policy, dependent: :destroy

  before_save :generate_tag
  after_create :create_fallback_policy
  after_update :update_fallback_policy

  audited

  def fallback_policy
    policies.where(fallback: true).first
  end

private

  def generate_tag
    self.tag = name.parameterize(separator: "_")
  end

  def create_fallback_policy
    return if policies.find_by(fallback: true)

    fallback_policy =
      Policy.new(
        name: "Fallback policy for #{name}",
        description: "Default fallback policy for #{name}",
        fallback: true,
        action: "reject",
      )
    if fallback_policy.save
      policies << fallback_policy
    else
      errors.add :name, "Failed to generate fallback policy with error: #{fallback_policy.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid
    end
  end

  def update_fallback_policy
    fallback_policy = policies.find_by(fallback: true)

    fallback_policy&.update(
      name: "Fallback policy for #{name}",
      description: "Default fallback policy for #{name}",
    )
  end

  def skip_uniqueness_validation?
    false
  end


  def self.ransackable_associations(_auth_object = nil)
    %w[audits clients mac_authentication_bypasses policies site_policy]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name policy_count tag updated_at]
  end
end
