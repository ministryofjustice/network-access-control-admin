class ClientPresenter < BasePresenter
  def display_name
    "IP: #{record.ip_range}, Tag: #{record.tag}, Site: #{record.site.name}"
  end
end
