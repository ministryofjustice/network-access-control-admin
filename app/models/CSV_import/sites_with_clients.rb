module CSVImport
  require "csv"

  class SitesWithClients
    include ActiveModel::Validations

    attr_accessor :records

    def initialize(csv)
      @csv = remove_utf8_byte_order_mark(csv) if csv
      @records = []

      @records = parse_csv(@csv)
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

  private

    def parse_csv(csv)
      id_of_last_site = Site.last&.id || 0
      last_client_id = Client.last&.id || 0
      last_policy_id = Policy.last&.id || 0
      last_response_id = Response.last&.id || 0

      CSV.parse(csv, headers: true).map.with_index(1) do |row, i|
        site_name = row["Site Name"]
        eap_clients = row["EAP Clients"]
        radsec_clients = row["RadSec Clients"]
        policies = row["Policies"]
        fallback_policy = row["Fallback Policy"]

        record = Site.new(
          id: id_of_last_site + i,
          name: site_name,
        )

        record.policies << Policy.new(
          id: last_policy_id + i,
          name: "Fallback policy for #{site_name}",
          description: "Default fallback policy for #{site_name}",
          fallback: true,
        )

        unwrap_responses(fallback_policy).each.with_index(1) do |fallback_policy_response, fallback_policy_response_index|
          fallback_policy_response.id = last_response_id + fallback_policy_response_index
          fallback_policy_response.policy_id = record.policies.last.id

          record.policies.first.responses << fallback_policy_response
        end

        last_response_id += record.policies.first.responses.to_a.count

        policies.split(";").each do |policy|
          record.policies << Policy.find_by(name: policy)
        end

        eap_clients.split(";").each.with_index(1) do |eap_client, eap_client_index|
          record.clients << Client.new(id: last_client_id + eap_client_index, ip_range: eap_client, radsec: false)
        end

        radsec_clients.split(";").each.with_index(1) do |radsec_client, radsec_client_index|
          record.clients << Client.new(id: record.clients.last.id + radsec_client_index, ip_range: radsec_client, radsec: true)
        end

        record
      end
    end

    def remove_utf8_byte_order_mark(content)
      return content[3..] if "\xEF\xBB\xBFA".force_encoding("ASCII-8BIT") == content[0..3]

      content
    end

    def unwrap_responses(fallback_policy_responses)
      fallback_policy_responses.to_s.split(";").map do |r|
        response_attribute, value = r.split("=")
        PolicyResponse.new(response_attribute: response_attribute, value: value)
      end
    end
  end
end
