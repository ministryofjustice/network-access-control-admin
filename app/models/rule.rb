class Rule < ApplicationRecord
  belongs_to :policy

  after_save :update_rule_count

  validates_presence_of :request_attribute, :operator, :value
  validates_inclusion_of :operator, in: %w[equals contains]
  validate :validate_rule, on: %i[create update]

  audited

private

  def validate_rule
    return if request_attribute.blank?

    result = UseCases::ValidateRadiusAttribute.new.call(attribute: request_attribute, value: value)

    unless result.fetch(:success)
      errors.add(:request_attribute, result.fetch(:message))
    end
  end

  def update_rule_count
    policy.update_attribute(:rule_count, policy.rules.count)
  end
end
