class ResponsePresenter < BasePresenter
  def display_name
    "#{record.response_attribute}-#{record.value}, Policy: #{record.policy.name}"
  end
end
