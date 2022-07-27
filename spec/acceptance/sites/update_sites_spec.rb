require "rails_helper"

describe "update sites", type: :feature do
  let(:site) { create(:site) }

  context "when the user is a unauthenticated" do
    it "does not allow creating sites" do
      visit "/sites/#{site.to_param}/edit"

      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when the user is a viewer" do
    before do
      login_as create(:user, :reader)
    end

    it "does not allow editing sites" do
      visit "/sites"

      expect(page).not_to have_content "Edit"

      visit "/sites/#{site.to_param}/edit"

      expect(page).to have_content "You are not authorized to access this page."
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

    it "update an existing site" do
      expect_service_deployment
      expect(Gateways::S3).to receive(:new).with(expected_s3_gateway_config).and_return(s3_gateway)
      expect(UseCases::ConfigValidator).to receive(:new).and_return(config_validator)

      expect(UseCases::PublishToS3).to receive(:new).with(
        destination_gateway: s3_gateway,
        config_validator:,
      ).and_return(publish_to_s3)

      visit "/sites/#{site.id}"

      first(:link, "Change").click

      expect(page).to have_field("Name", with: site.name)

      fill_in "Name", with: "My Manchester Site"

      click_on "Update"

      expect(current_path).to eq("/sites/#{site.id}")

      expect(page).to have_content("My Manchester Site")
      expect(page).to have_content("Successfully updated site.")
      expect(page).to have_content("This could take up to 10 minutes to apply.")

      expect_audit_log_entry_for(editor.email, "update", "Site")
    end
  end
end
