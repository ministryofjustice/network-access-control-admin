class Rule < ApplicationRecord
  belongs_to :policy

  before_validation :format_request_attribute
  after_save :update_rule_count

  validates_presence_of :request_attribute, :operator, :value
  validates_inclusion_of :operator, in: %w[equals contains]
  validate :validate_uniqueness_of_request_attribute, on: %i[create update]
  validate :validate_rule, on: %i[create update]

  audited

private

  def validate_uniqueness_of_request_attribute
    return if request_attribute.blank? || policy.nil?

    errors.add(:request_attribute, "has already been added") if policy.rules.where(request_attribute: request_attribute).any?
  end

  def validate_rule
    return if request_attribute.blank? || errors.key?(:request_attribute)

    result = UseCases::ValidateRadiusAttribute.new.call(attribute: request_attribute, value: value)

    unless result.fetch(:success)
      errors.add(:request_attribute, result.fetch(:message))
    end
  end

  def format_request_attribute
    request_attribute.strip! if request_attribute
  end

  def update_rule_count
    policy.update_attribute(:rule_count, policy.rules.count)
  end
end
