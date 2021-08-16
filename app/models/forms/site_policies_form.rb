module Forms
  class SitePoliciesForm
    include ActiveModel::Model

    validate :validate_number_of_fallback_policies

    attr_accessor :policies

    def self.build_from_site(site)
      policies = site.policies

      new(policies: policies)
    end

    def save(site)
      return false unless valid?

      site.update(policies: policies)
    end

  private

    def validate_number_of_fallback_policies
      errors.add(:policies, "can only have one fallback policy") if policies.select(&:fallback).count > 1
    end
  end
end
