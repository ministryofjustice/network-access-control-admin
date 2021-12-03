class HomeController < ApplicationController
  def index
    @stats = [
      { label: "Sites", count: Site.all.count, link: sites_path },
      { label: "MAC Adresses", count: MacAuthenticationBypass.all.count, link: mac_authentication_bypasses_path },
      { label: "Policies", count: Policy.all.count, link: policies_path },
      { label: "Certificates", count: Certificate.all.count, link: certificates_path },
      { label: "Clients", count: Client.all.count },
      { label: "Rules", count: Rule.all.count },
      { label: "Responses", count: Response.all.count },
    ]
  end
end
