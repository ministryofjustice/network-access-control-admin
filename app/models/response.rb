class Response < ApplicationRecord
  validates_presence_of :response_attribute, :value
  validate :validate_response, on: %i[create update]

  audited

private

  def validate_response
    return if response_attribute.blank?

    result = UseCases::ValidateRadiusAttribute.new.call(attribute: response_attribute, value: value)

    unless result.fetch(:success)
      errors.add(:response_attribute, result.fetch(:message))
    end
  end
end
