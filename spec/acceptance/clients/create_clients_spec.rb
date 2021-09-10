require "rails_helper"

describe "create clients", type: :feature do
  context "when the user is an editor" do
    let(:editor) { create(:user, :editor) }
    let(:publish_to_s3) { instance_double(UseCases::PublishToS3) }
    let(:s3_gateway) { double(Gateways::S3) }
    let(:deploy_service) { instance_double(UseCases::DeployService) }
    let(:ecs_gateway) { double(Gateways::Ecs) }

    before do
      login_as editor
    end

    context "when there is an existing site" do
      let!(:site) { create(:site, name: "Your Site") }
      let(:expected_s3_gateway_config) do
        {
          bucket: ENV.fetch("RADIUS_CONFIG_BUCKET_NAME"),
          key: "clients.conf",
          aws_config: Rails.application.config.s3_aws_config,
          content_type: "text/plain",
        }
      end

      let(:expected_ecs_gateway_config) do
        {
          cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
          service_name: ENV.fetch("RADIUS_SERVICE_NAME"),
          aws_config: Rails.application.config.ecs_aws_config,
        }
      end

      let(:expected_ecs_gateway_config_internal) do
        {
          cluster_name: ENV.fetch("RADIUS_CLUSTER_NAME"),
          service_name: ENV.fetch("RADIUS_INTERNAL_SERVICE_NAME"),
          aws_config: Rails.application.config.ecs_aws_config,
        }
      end

      before(:each) do
        allow(publish_to_s3).to receive(:call)
        allow(deploy_service).to receive(:call)
      end

      it "creates a new client" do
        expect(Gateways::S3).to receive(:new).with(expected_s3_gateway_config).and_return(s3_gateway)
        expect(UseCases::PublishToS3).to receive(:new).with(destination_gateway: s3_gateway).and_return(publish_to_s3)

        expect(Gateways::Ecs).to receive(:new).with(expected_ecs_gateway_config).and_return(ecs_gateway)
        expect(UseCases::DeployService).to receive(:new).with(ecs_gateway: ecs_gateway).and_return(deploy_service)

        expect(Gateways::Ecs).to receive(:new).with(expected_ecs_gateway_config_internal).and_return(ecs_gateway)
        expect(UseCases::DeployService).to receive(:new).with(ecs_gateway: ecs_gateway).and_return(deploy_service)

        visit "/sites/#{site.id}"

        click_on "Add client"

        expect(page.current_path).to eq(new_site_client_path(site_id: site))

        fill_in "IP / Subnet CIDR", with: "123.123.123.123/32"

        click_on "Create"

        expected_config_file = "client 123.123.123.123/32 {
\tipv4addr = 123.123.123.123/32
\tsecret = #{Client.first.shared_secret}
\tshortname = your_site
}

clients radsec {
}"

        expect(publish_to_s3).to have_received(:call).with(expected_config_file)
        expect(deploy_service).to have_received(:call).twice

        expect(page).to have_content("Successfully created client.")
        expect(page.current_path).to eq(site_path(id: site.id))
        expect(page).to have_content("123.123.123.123/32")
        expect(page).not_to have_content("radsec")

        expect_audit_log_entry_for(editor.email, "create", "Client")
      end

      it "creates a new RadSec client" do
        expect(Gateways::S3).to receive(:new).with(expected_s3_gateway_config).and_return(s3_gateway)
        expect(UseCases::PublishToS3).to receive(:new).with(destination_gateway: s3_gateway).and_return(publish_to_s3)

        expect(Gateways::Ecs).to receive(:new).with(expected_ecs_gateway_config).and_return(ecs_gateway)
        expect(UseCases::DeployService).to receive(:new).with(ecs_gateway: ecs_gateway).and_return(deploy_service)

        expect(Gateways::Ecs).to receive(:new).with(expected_ecs_gateway_config_internal).and_return(ecs_gateway)
        expect(UseCases::DeployService).to receive(:new).with(ecs_gateway: ecs_gateway).and_return(deploy_service)

        visit "/sites/#{site.id}"

        click_on "Add client"

        check("RadSec", allow_label_click: true)

        fill_in "IP / Subnet CIDR", with: "123.123.123.123/32"

        click_on "Create"

        expected_config_file = "clients radsec {
\tclient 123.123.123.123/32 {
\t\tipv4addr = 123.123.123.123/32
\t\tsecret = radsec
\t\tshortname = your_site
\t\tproto = tls
\t}\n
}"

        expect(publish_to_s3).to have_received(:call).with(expected_config_file)
        expect(deploy_service).to have_received(:call).twice

        expect(page).to have_content("Successfully created client.")
        expect(page).to have_content("123.123.123.123/32")
        expect(page).to have_content("radsec")

        expect_audit_log_entry_for(editor.email, "create", "Client")
      end

      it "displays error if form cannot be submitted" do
        visit new_site_client_path(site_id: site)

        click_on "Create"

        expect(page).to have_content "There is a problem"
      end
    end
  end
end
