class HomeController < ApplicationController
  def index
    @stats = [
      { label: "Sites", count: Site.all.count },
      { label: "Clients", count: Client.all.count },
      { label: "MAC Adresses", count: MacAuthenticationBypass.all.count },
      { label: "Policies", count: Policy.all.count },
      { label: "Rules", count: Rule.all.count },
      { label: "Responses", count: Response.all.count },
      { label: "Certificates", count: Certificate.all.count },
    ]
  end
end
