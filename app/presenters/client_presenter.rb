class ClientPresenter < BasePresenter
  def display_name
    "IP: #{record.ip_range}, Site: #{record.site.name}"
  end
end
