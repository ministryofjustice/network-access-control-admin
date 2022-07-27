require "rails_helper"

describe "delete sites", type: :feature do
  let!(:site) { create(:site) }

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting sites" do
      visit "/sites/#{site.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }
    let(:config_validator) { double(UseCases::ConfigValidator) }
    let(:publish_to_s3) { instance_double(UseCases::PublishToS3) }
    let(:s3_gateway) { double(Gateways::S3) }
    let(:expected_s3_gateway_config) do
      {
        bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
        key: "clients.conf",
        aws_config: Rails.application.config.s3_aws_config,
        content_type: "text/plain",
      }
    end

    before do
      login_as editor
      site
      allow(publish_to_s3).to receive(:call)
    end

    it "delete a site" do
      expect_service_deployment
      expect(Gateways::S3).to receive(:new).with(expected_s3_gateway_config).and_return(s3_gateway)
      expect(UseCases::ConfigValidator).to receive(:new).and_return(config_validator)

      expect(UseCases::PublishToS3).to receive(:new).with(
        destination_gateway: s3_gateway,
        config_validator:,
      ).and_return(publish_to_s3)
      
      visit "/sites/#{site.id}"

      find_link("Delete site", href: "/sites/#{site.id}").click

      expect(page).to have_content("Are you sure you want to delete this site?")
      expect(page).to have_content(site.name)
      expect(page).to have_content("#{site.clients.count} clients will be deleted.")
      expect(page).to have_content("#{site.policies.count} policy will be detached.")

      click_on "Delete site"

      expect(current_path).to eq("/sites")
      expect(page).to have_content("Successfully deleted site.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")
      expect(page).not_to have_content(site.name)

      expect_audit_log_entry_for(editor.email, "destroy", "Site")
    end
  end
end
