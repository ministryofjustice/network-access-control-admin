class MabResponse < Response
  belongs_to :mac_authentication_bypass, optional: true

  validate :validate_uniqueness_of_response_attribute, on: %i[create update]

private

  def validate_uniqueness_of_response_attribute
    return if response_attribute.blank? || mac_authentication_bypass.nil?

    matching_attribute = mac_authentication_bypass.responses.where(response_attribute:).first

    errors.add(:response_attribute, "has already been added") if matching_attribute && matching_attribute.id != id
  end
end
