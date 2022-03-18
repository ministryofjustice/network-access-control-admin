require "rails_helper"

describe UseCases::DeployService do
  subject(:use_case) do
    described_class.new(
      ecs_gateway:,
    )
  end

  context "when there are no in flight deployments" do
    let(:ecs_gateway) { instance_double(Gateways::Ecs, update_service: nil) }

    it "deploys the network access control admin service" do
      use_case.call
      expect(ecs_gateway).to have_received(:update_service)
    end
  end

  context "when the maximum number of deployments has been reached" do
    let(:ecs_gateway) { instance_double(Gateways::Ecs, update_service: nil) }

    before do
      allow(ecs_gateway).to receive(:update_service).and_raise("Aws::ECS::Errors::InvalidParameterException")
    end

    it "does not schedule another deployment" do
      expect { use_case.call }.not_to raise_error
    end
  end
end
