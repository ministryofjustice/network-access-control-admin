class Rule < ApplicationRecord
  belongs_to :policy

  after_save :update_rule_count

  validates_presence_of :request_attribute, :operator, :value
  validates_inclusion_of :operator, in: %w[equals contains]
  validate :validate_radius_attributes, on: %i[create update]

  audited

private

  def validate_radius_attributes
    return if request_attribute.blank?

    errors.add(:request_attribute, "is invalid") unless AttributesHelper.valid_radius_attribute?(request_attribute)
  end

  def update_rule_count
    policy.update_attribute(:rule_count, policy.rules.count)
  end
end
