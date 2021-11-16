class Rule < ApplicationRecord
  include ApplicationRecordHelper

  belongs_to :policy

  before_validation -> { trim_white_space(request_attribute, value) }
  after_save :update_rule_count

  validates_presence_of :request_attribute, :operator, :value
  validates_inclusion_of :operator, in: %w[equals contains]
  validate :validate_uniqueness_of_request_attribute, on: %i[create update]
  validate -> { validate_radius_attribute(request_attribute, value) }, on: %i[create update]

  audited

private

  def validate_uniqueness_of_request_attribute
    return if request_attribute.blank? || policy.nil?

    matching_attribute = policy.rules.where(request_attribute: request_attribute).first

    errors.add(:request_attribute, "has already been added") if matching_attribute && matching_attribute.id != id
  end

  def update_rule_count
    policy.update_attribute(:rule_count, policy.rules.count)
  end
end
