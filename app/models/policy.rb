class Policy < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }, unless: :skip_uniqueness_validation?
  validates_presence_of :description

  has_many :rules, dependent: :destroy
  has_many :responses, dependent: :destroy

  has_many :site_policy
  has_many :sites, through: :site_policy, dependent: :destroy

  after_save :update_action

  audited

private

  def skip_uniqueness_validation?
    false
  end

  def update_action
    responses.find_by(response_attribute: "Post-Auth-Type").try(:delete)

    if action == "reject"
      responses << Response.create!(response_attribute: "Post-Auth-Type", value: "Reject")
    end
  end

  # rubocop:disable Lint/IneffectiveAccessModifier
  def self.ransackable_attributes(_auth_object = nil)
    %w[action created_at description fallback id name rule_count site_count updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[audits responses rules site_policy sites]
  end
  # rubocop:enable Lint/IneffectiveAccessModifier
end
