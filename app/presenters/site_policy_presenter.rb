class SitePolicyPresenter < BasePresenter
  def display_name
    "#{record.site_id} - #{record.policy_id} - #{record.priority}"
  end
end
