# frozen_string_literal: true

class RulePresenter < BasePresenter
  def display_name
    "#{record.request_attribute}-#{record.operator}-#{record.value}, Policy: #{record.policy.name}"
  end
end
