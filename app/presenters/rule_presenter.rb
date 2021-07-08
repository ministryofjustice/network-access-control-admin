class RulePresenter < BasePresenter
  def display_name
    "Prolicy: #{record.policy.name}, Rule: #{record.request_attribute}-#{record.operator}-#{record.value}"
  end
end
