module CSVImport
  class SitesWithClients
    include ActiveModel::Validations

    attr_accessor :records

    def initialize(parse_csv)
      @records = parse_csv.call
    end

    def save
      return false unless valid?

      sites_to_save = []
      clients_to_save = []
      fallback_policies_to_save = []
      fallback_policy_responses_to_save = []
      site_policies_to_save = []

      @records.each do |site|
        sites_to_save << { id: site.id, name: site.name, tag: site.name.parameterize(separator: "_"), policy_count: site.policies.to_a.count }

        site.clients.each do |client|
          client.valid?
          clients_to_save << { ip_range: client.ip_range, shared_secret: client.shared_secret, site_id: site.id, radsec: client.radsec }
        end

        site.policies.each do |policy|
          if policy.fallback?
            fallback_policies_to_save << {
              name: policy.name,
              description: policy.description,
              fallback: policy.fallback,
              rule_count: policy.rule_count,
              site_count: 1,
            }

            policy.responses.each do |response|
              fallback_policy_responses_to_save << { policy_id: policy.id, response_attribute: response.response_attribute, value: response.value }
            end
          end

          site_policies_to_save << { site_id: site.id, policy_id: policy.id }
        end
      end

      ActiveRecord::Base.transaction do
        Site.insert_all(sites_to_save)
        Client.insert_all(clients_to_save)
        Policy.insert_all(fallback_policies_to_save)
        PolicyResponse.insert_all(fallback_policy_responses_to_save)
        SitePolicy.insert_all(site_policies_to_save)
      end
    end
  end
end
