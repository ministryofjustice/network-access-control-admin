class ResponsePresenter < BasePresenter
  def display_name
    "#{record.response_attribute}-#{record.value}, #{relation}"
  end

private

  def relation
    if record.policy_id
      "Policy: #{Policy.find_by_id(record.policy_id).name}"
    else
      "MAB: #{MacAuthenticationBypass.find_by_id(record.mac_authentication_bypass_id).name}"
    end
  end
end
