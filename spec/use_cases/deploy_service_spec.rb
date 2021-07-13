require "rails_helper"

describe UseCases::DeployService do
  subject(:use_case) do
    described_class.new(
      ecs_gateway: ecs_gateway,
    )
  end

  let(:ecs_gateway) { instance_spy(Gateways::Ecs) }

  before do
    use_case.call
  end

  it "deploys the network access control admin service" do
    expect(ecs_gateway).to have_received(:update_service)
  end
end
