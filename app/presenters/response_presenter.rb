class ResponsePresenter < BasePresenter
  def display_name
    relation = record.policy_id ? "Policy: #{Policy.find_by_id(record.policy_id).name}" : "MAB: #{MacAuthenticationBypass.find_by_id(record.mac_authentication_bypass_id).name}"
    "#{record.response_attribute}-#{record.value}, #{relation}"
  end
end
