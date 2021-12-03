require "rails_helper"

describe "delete clients", type: :feature do
  context "when the user is a viewer" do
    let(:editor) { create(:user, :editor) }
    let!(:site) { create(:site) }

    before do
      login_as create(:user, :reader)
    end

    it "does not allow deleting clients" do
      visit "/sites/#{site.id}"

      expect(page).not_to have_content "Delete"
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
    end

    context "when there is an existing site with a client" do
      let!(:site) { create(:site) }
      let!(:client) { create(:client, site: site) }
      let(:publish_to_s3) { instance_double(UseCases::PublishToS3) }
      let(:s3_gateway) { double(Gateways::S3) }
      let(:config_validator) { double(UseCases::ConfigValidator) }

      it "deletes an existing client" do
        expect_service_deployment

        allow(publish_to_s3).to receive(:call)

        expected_s3_gateway_config = {
          bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
          key: "clients.conf",
          aws_config: Rails.application.config.s3_aws_config,
          content_type: "text/plain",
        }

        expect(Gateways::S3).to receive(:new).with(expected_s3_gateway_config).and_return(s3_gateway)
        expect(UseCases::ConfigValidator).to receive(:new).and_return(config_validator)
        expect(UseCases::PublishToS3).to receive(:new).with(
          destination_gateway: s3_gateway,
          config_validator: config_validator,
        ).and_return(publish_to_s3)

        visit "/sites/#{site.id}"

        find_link("Delete", href: "/sites/#{site.id}/clients/#{client.id}").click

        expect(page).to have_content("Are you sure you want to delete this client?")
        expect(page).to have_content(client.ip_range)
        expect(page).to have_content(client.site.tag)

        click_on "Delete client"

        expected_config_file = "clients radsec {\n}"

        expect(publish_to_s3).to have_received(:call).with(expected_config_file)
        expect(current_path).to eq("/sites/#{site.id}")

        expect(page).to have_content("Successfully deleted client.")
        expect(page).not_to have_content(client.ip_range)
        expect(page).not_to have_content(client.shared_secret)

        expect_audit_log_entry_for(editor.email, "destroy", "Client")
      end
    end
  end
end
