class Response < ApplicationRecord
  validates_presence_of :response_attribute, :value
  validate :validate_radius_attributes, on: %i[create update]

  audited

private

  def validate_radius_attributes
    return if response_attribute.blank?

    errors.add(:response_attribute, "is invalid") unless AttributesHelper.valid_radius_attribute?(response_attribute)
  end
end
