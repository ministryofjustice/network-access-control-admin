describe Gateways::Ecs do
  subject(:gateway) { described_class.new(cluster_name: cluster_name, service_name: service_name, aws_config: aws_config) }

  let(:cluster_name) { "some-cluster-name" }
  let(:service_name) { "some-service-name" }
  let(:aws_config) do
    {
      region: "eu-west-2",
      stub_responses: true,
    }
  end

  it "calls update service on the ECS AWS SDK" do
    expect(gateway.update_service).to eq({})
  end
end
