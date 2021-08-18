class MacAuthenticationBypassResponsePresenter < BasePresenter
  def display_name
    "#{record.response_attribute}-#{record.value}, MAB: #{record.mac_authentication_bypass.name}"
  end
end
