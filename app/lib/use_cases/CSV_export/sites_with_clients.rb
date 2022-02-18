module UseCases
  class CSVExport::SitesWithClients
    CSV_HEADERS = "Client,Shared Secret,Site Name".freeze

    def call
      clients = Client.all.includes(:site)
      content = "#{CSV_HEADERS}\n"

      clients.each do |client|
        content << "#{client.ip_range},#{client.shared_secret},#{client.site.name}\n"
      end
      content
    end
  end
end
