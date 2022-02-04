class SitePolicy < ApplicationRecord
  belongs_to :site
  belongs_to :policy

  after_save :update_site_count, :update_policy_count
  after_destroy :update_site_count, :update_policy_count, :destroy_fallback_policy

  audited

  def update_site_count
    policy.update_attribute(:site_count, policy.reload.sites.count)
  end

  def update_policy_count
    site.update_attribute(:policy_count, site.reload.policies.count)
  end

  def destroy_fallback_policy
    policy.destroy if policy.fallback?
  end
end
