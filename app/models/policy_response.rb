class PolicyResponse < Response
  belongs_to :policy

  def policy
    Policy.find_by_id(policy_id)
  end
end
