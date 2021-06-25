class SitePresenter < BasePresenter
  def display_name
    record.name
  end
end
