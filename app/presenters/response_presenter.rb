class ResponsePresenter < BasePresenter
  def display_name
    "#{record.response_attribute}-#{record.value}, Policy: #{Policy.find_by_id(record.policy_id).name}"
  end
end
