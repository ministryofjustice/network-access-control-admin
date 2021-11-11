class PolicyResponse < Response
  belongs_to :policy

  validate :validate_uniqueness_of_response_attribute, on: %i[create update]

private

  def validate_uniqueness_of_response_attribute
    return if response_attribute.blank? || policy.nil?

    errors.add(:response_attribute, "has already been added for this policy") if policy.responses.where(response_attribute: response_attribute).any?
  end
end
