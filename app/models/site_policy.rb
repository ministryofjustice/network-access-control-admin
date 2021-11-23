class SitePolicy < ApplicationRecord
  belongs_to :site
  belongs_to :policy

  after_save :update_site_count, :update_policy_count

  audited

  def update_site_count
    policy.update_attribute(:site_count, policy.sites.count)
  end

  def update_policy_count
    site.update_attribute(:policy_count, site.policies.count)
  end
end
