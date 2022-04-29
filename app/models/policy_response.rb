class PolicyResponse < Response
  belongs_to :policy

  validate :validate_uniqueness_of_response_attribute, on: %i[create update]

  after_save :ensure_policy_action

private

  def validate_uniqueness_of_response_attribute
    return if response_attribute.blank? || policy.nil?

    matching_attribute = policy.responses.where(response_attribute:).first

    errors.add(:response_attribute, "has already been added") if matching_attribute && matching_attribute.id != id
  end

  def ensure_policy_action
    if policy.responses.find_by(response_attribute: "Post-Auth-Type")
      policy.update(action: "reject")
    end
  end
end
