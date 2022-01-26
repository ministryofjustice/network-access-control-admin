module UseCases
  require "csv"
  class CSVImport::ParseSitesWithClients
    CSV_HEADERS = "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy".freeze

    def initialize(file_contents)
      @file_contents = remove_utf8_byte_order_mark(file_contents) if file_contents
      @errors = []
    end

    def call
      validate_csv

      return { errors: @errors } if @errors.any?

      all_policies = Policy.all
      last_site_id = Site.last&.id || 0
      last_client_id = Client.last&.id || 0
      last_policy_id = all_policies.last&.id || 0
      last_response_id = Response.last&.id || 0

      records = CSV.parse(@file_contents, headers: true).map.with_index(1) do |row, i|
        site_name = row["Site Name"]
        eap_clients = row["EAP Clients"]
        radsec_clients = row["RadSec Clients"]
        policies = row["Policies"]
        fallback_policy = row["Fallback Policy"]

        record = CSVImport::Site.new(
          id: last_site_id + i,
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

        assign_policies(policies, all_policies, record, i + 1)

        map_clients(eap_clients, radsec_clients, record, last_client_id)

        record
      end

      { records: records, errors: @errors }
    end

  private

    def assign_policies(policies, all_policies, record, row)
      return unless policies

      policies.split(";").each do |policy_name|
        policy = all_policies.detect { |p| p.name == policy_name }

        if policy.present?
          record.policies << policy
        else
          @errors << "Error on row #{row}: Policy #{policy_name} is not found"
        end
      end
    end

    def map_clients(eap_clients, radsec_clients, record, last_client_id)
      if eap_clients
        eap_clients.split(";").each.with_index(1) do |eap_client, eap_client_index|
          record.clients << Client.new(id: last_client_id + eap_client_index, ip_range: eap_client, radsec: false)
        end
      end

      if radsec_clients
        radsec_clients.split(";").each.with_index(1) do |radsec_client, radsec_client_index|
          record.clients << Client.new(id: record.clients.last.id + radsec_client_index, ip_range: radsec_client, radsec: true)
        end
      end
    end

    def unwrap_responses(fallback_policy_responses)
      fallback_policy_responses.to_s.split(";").map do |r|
        response_attribute, value = r.split("=")
        Response.new(response_attribute: response_attribute, value: value)
      end
    end

    def remove_utf8_byte_order_mark(content)
      return content[3..] if "\xEF\xBB\xBFA".force_encoding("ASCII-8BIT") == content[0..3]

      content
    end

    def validate_csv
      return @errors << "CSV is missing" unless @file_contents
      return @errors << "The CSV header is invalid" unless valid_header?

      @errors << "There is no data to be imported" unless @file_contents.split("\n").second
    end

    def valid_header?
      @file_contents.to_s.lines.first&.strip == CSV_HEADERS
    end
  end
end
