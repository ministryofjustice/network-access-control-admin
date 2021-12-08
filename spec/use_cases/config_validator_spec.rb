require "rails_helper"

describe UseCases::ConfigValidator do
  let(:config_file_path) { "/etc/raddb/mods-config/files/authorize" }

  context "with a valid configuration" do
    it "does not raise an error" do
      expect { described_class.new(config_file_path: config_file_path, content: "").call }.to_not raise_error
    end
  end

  context "with an invalid configration" do
    it "raises an error" do
      expect { described_class.new(config_file_path: config_file_path, content: "something invalid").call }.to raise_error(SystemExit)
    end
  end
end
