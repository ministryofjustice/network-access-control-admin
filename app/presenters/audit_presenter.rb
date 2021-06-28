class AuditPresenter < BasePresenter
  def name
    string = record.auditable_type.underscore.humanize

    return string if record.auditable.blank?

    if auditable_presenter.display_name.present?
      string += " (#{auditable_presenter.display_name})"
    end

    string
  end

  private

  def auditable_presenter
    model = record.auditable
    presenter = "#{model.class}Presenter".constantize
    presenter.new(model)
  end
end
