# frozen_string_literal: true

class AuditPresenter < BasePresenter
  def name
    string = record.auditable_type.underscore.humanize

    return string if record.auditable.blank?

    string += " (#{auditable_presenter.display_name})" if auditable_presenter.display_name.present?

    string
  end

private

  def auditable_presenter
    model = record.auditable
    presenter = "#{model.class}Presenter".constantize
    presenter.new(model)
  end
end
