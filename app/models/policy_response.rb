class PolicyResponse < Response
  belongs_to :policy, optional: true

  validate :validate_uniqueness_of_response_attribute, on: %i[create update]

private

  def validate_uniqueness_of_response_attribute
    return if response_attribute.blank? || policy.nil?

    matching_attribute = policy.responses.where(response_attribute: response_attribute).first

    errors.add(:response_attribute, "has already been added") if matching_attribute && matching_attribute.id != id
  end
end
