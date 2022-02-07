module ApplicationHelper
  def field_error(resource, key)
    resource&.errors&.include?(key.to_sym) ? "govuk-form-group--error" : ""
  end

  def selected_class_if_controller(controller_names)
    " govuk-header__navigation-item--active" if [controller_names].flatten.include?(controller_name)
  end

  def present(model)
    presenter = "#{model.class}Presenter".constantize
    presenter.new(model)
  end

  def navigation_crumbs
    @navigation_crumbs ||= []
  end

  def date_format(date)
    date.strftime("%d/%m/%Y %H:%M")
  end
end
