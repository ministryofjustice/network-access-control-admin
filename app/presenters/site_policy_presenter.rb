class SitePolicyPresenter < BasePresenter
  def display_name
    "#{site_relation} - #{policy_relation}"
  end

private

  def policy_relation
    if record.policy_id
      "Policy: #{Policy.find_by_id(record.policy_id).try(:name)}"
    end
  end

  def site_relation
    if record.site_id
      "Site: #{Site.find_by_id(record.site_id).try(:name)}"
    end
  end
end
