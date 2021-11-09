class Response < ApplicationRecord
  before_validation :format_response_attribute

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

  def format_response_attribute
    response_attribute.strip! if response_attribute
  end
end
