# frozen_string_literal: true

class PolicyPresenter < BasePresenter
  def display_name
    record.name
  end
end
