require "rails_helper"

class FakeValidConfigValidator
  def initialize(config_file_path:, contents:); end
  def call() = nil
end

class FakeInvalidConfigValidator
  def initialize(config_file_path:, contents:); end
  def call() = abort("error")
end

describe UseCases::PublishToS3 do
  let(:s3_gateway) { instance_spy(Gateways::S3) }
  let(:config) { "some file contents" }

  subject(:use_case) { described_class.new(destination_gateway: s3_gateway, config_validator:) }

  context "with a valid configuration" do
    let(:config_validator) { FakeValidConfigValidator.new(config_file_path: "/something", contents: "stub") }

    it "publishes the file with contents" do
      use_case.call(config)
      expect(s3_gateway).to have_received(:write).with(data: config)
    end
  end

  context "with an invalid configuration" do
    let(:config_validator) { FakeInvalidConfigValidator.new(config_file_path: "/something", contents: "stub") }

    it "does not publish the file with contents" do
      expect { use_case.call(config) }.to raise_error(SystemExit)
      expect(s3_gateway).to_not have_received(:write).with(data: config)
    end
  end
end
