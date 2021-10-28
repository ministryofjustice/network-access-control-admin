class Response < ApplicationRecord
  validates_presence_of :response_attribute, :value
  validate :validate_radius_attributes, on: :create

  audited

private

  def validate_radius_attributes
    return if response_attribute.blank?

    errors.add(:response_attribute, "is invalid") unless File.read("app/helpers/radius_dictionary_attributes.txt").include?(response_attribute)
  end
end
