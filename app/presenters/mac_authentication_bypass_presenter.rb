class MacAuthenticationBypassPresenter < BasePresenter
  def display_name
    "#{record.address} #{record.name} #{record.description}"
  end
end
