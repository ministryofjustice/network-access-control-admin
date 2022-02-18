require "rails_helper"

describe UseCases::CSVExport::SitesWithClients do
  subject { described_class.new }
  context "when there are sites with clients" do
    let!(:site_one) { create(:site) }
    let!(:site_two) { create(:site) }
    let!(:site_three) { create(:site) }
    let!(:eap_client_one) { create(:client, site: site_one) }
    let!(:eap_client_two) { create(:client, site: site_two) }
    let!(:radsec_client_one) { create(:client, radsec: true, site: site_three) }

    it "generates a CSV file" do
      rows = subject.call.split("\n")

      expect(rows.first).to eq("Client,Shared Secret,Site Name")
      expect(rows.second).to eq("#{eap_client_one.ip_range},#{eap_client_one.shared_secret},#{site_one.name}")
      expect(rows.third).to eq("#{eap_client_two.ip_range},#{eap_client_two.shared_secret},#{site_two.name}")
      expect(rows.fourth).to eq("#{radsec_client_one.ip_range},#{radsec_client_one.shared_secret},#{site_three.name}")
    end
  end
end
