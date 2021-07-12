# frozen_string_literal: true

require "rails_helper"

describe AuditPresenter do
  describe "#name" do
    it "returns the auditable type if the auditable is nil (i.e deleted)" do
      audit = double(auditable_type: "Site", auditable: nil)
      presenter = AuditPresenter.new(audit)

      expect(presenter.name).to eq("Site")
    end

    it "appends the display name of the auditable presenter to the auditable type" do
      auditable = build_stubbed(:site, name: "Foobar")
      audit = double(auditable_type: "Site", auditable: auditable)
      presenter = AuditPresenter.new(audit)

      expect(presenter.name).to eq("Site (Foobar)")
    end
  end
end
