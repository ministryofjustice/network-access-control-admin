require "rails_helper"

describe "update clients", type: :feature do
  let(:site) { create(:site) }
  let(:client) { create(:client, site:) }
  let(:publish_to_s3) { instance_double(UseCases::PublishToS3) }
  let(:s3_gateway) { double(Gateways::S3) }
  let(:config_validator) { double(UseCases::ConfigValidator) }

  context "when the user is unauthenticated" do
    it "does not allow updating clients" do
      visit "/sites/#{site.id}/clients/#{client.id}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing clients" do
      visit "/sites/#{site.id}"

      expect(page).not_to have_content "Edit"

      visit "/sites/#{site.id}/clients/#{client.id}/edit"

      expect(page).to have_content "You are not authorized to access this page."
    end
  end

  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }

    before do
      login_as editor
      client
    end

    it "does update an existing client" do
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
        config_validator:,
      ).and_return(publish_to_s3)

      visit "sites/#{site.id}"

      first(:link, "Edit").click

      expect(page).to have_field("IP / Subnet CIDR", with: client.ip_range)
      expect(page).to have_content "It is recommended to use a combination of numbers and characters, with a minimum length of 20"
      expect(page).to have_field("Shared secret", with: client.shared_secret)

      fill_in "IP / Subnet CIDR", with: "132.111.132.111/32"
      fill_in "Shared secret", with: "UpdatedSharedSecret12345"

      expect(page).to have_field("RadSec", type: "checkbox", disabled: true, checked: false)

      click_on "Update"

      expected_config_file = "client 132.111.132.111/32 {
\tipv4addr = 132.111.132.111/32
\tsecret = UpdatedSharedSecret12345
\tshortname = #{Client.first.site.tag}
}

clients radsec {
}"

      expect(publish_to_s3).to have_received(:call).with(expected_config_file)
      expect(current_path).to eq("/sites/#{site.id}")

      expect(page).to have_content("Successfully updated client.")
      expect(page).to have_content "132.111.132.111/32"
      expect(page).to have_content "UpdatedSharedSecret12345"

      expect_audit_log_entry_for(editor.email, "update", "Client")
    end

    context "when the client is a RadSec client" do
      let(:client) { create(:client, radsec: true, site:, shared_secret: "radsec") }

      it "does not allow updating the client type" do
        visit "sites/#{site.id}"

        first(:link, "Edit").click

        expect(page).to have_field("RadSec", type: "checkbox", disabled: true, checked: true)
        expect(page).to_not have_field("Shared secret")
      end
    end
  end
end
