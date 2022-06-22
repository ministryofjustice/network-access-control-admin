module UseCases
  require "csv"

  class CSVImport::SitesWithClients < CSVImport::Base
    include ApplicationRecordHelper

    CSV_HEADERS = "Site Name,RADIUS Clients,RadSec Clients,Policies,Fallback Policy Responses".freeze

  private

    def map_csv_content
      @records = parsed_csv.map.with_index(1) do |row, i|
        site_name = row["Site Name"]
        eap_clients = row["RADIUS Clients"]
        radsec_clients = row["RadSec Clients"]
        policies = row["Policies"]
        fallback_policy_responses = row["Fallback Policy Responses"]

        record = Site.new(
          name: site_name,
        )

        record.policies << Policy.new(
          name: "Fallback policy for #{site_name}",
          description: "Default fallback policy for #{site_name}",
          fallback: true,
          action: fallback_policy_responses.nil? ? "reject" : "accept"
        )

        unwrap_responses(fallback_policy_responses).each do |fallback_policy_response|
          record.policies.first.responses << fallback_policy_response
        end

        assign_policies(policies, record, i)
        map_clients(eap_clients, radsec_clients, record)

        record
      end
    end

    def valid_csv?
      return @errors << "CSV is missing" && false if @csv_contents.nil?
      return @errors << "The file extension is invalid" && false unless valid_file_extension?
      return @errors << "The CSV header is invalid" && false unless valid_header?(CSV_HEADERS)
      return @errors << "There is no data to be imported" && false unless @csv_contents.split("\n").second

      check_for_duplicate_site_names
      check_for_duplicate_attributes("Fallback Policy Responses")
      check_for_ip_range_overlap

      @errors.empty?
    end

    def validate_records
      @records.each.with_index(2) do |record, row|
        record.validate

        record.errors.full_messages.each do |error|
          @errors << "Error on row #{row}: Site #{error}"
        end

        fetch_validation_errors(record.clients, row, "Client")

        fallback_policy = record.policies.first

        fallback_policy.errors.full_messages.each do |fallback_policy_error|
          @errors << "Error on row #{row}: Fallback Policy #{fallback_policy_error}"
        end

        fetch_validation_errors(fallback_policy.responses, row)
      end
    end

    def assign_policies(policies, record, row)
      return unless policies

      policies.split(";").each do |policy_name|
        policy = Policy.find_by_name(policy_name)

        if policy.present?
          record.policies << policy
        else
          @errors << "Error on row #{row}: Policy #{policy_name} is not found"
        end
      end
    end

    def map_clients(eap_clients, radsec_clients, record)
      if eap_clients
        eap_clients.split(";").each do |eap_client|
          record.clients << Client.new(ip_range: eap_client, radsec: false)
        end
      end

      if radsec_clients
        radsec_clients.split(";").each do |radsec_client|
          record.clients << Client.new(ip_range: radsec_client, radsec: true)
        end
      end
    end

    def check_for_duplicate_site_names
      site_names = parsed_csv.map do |row|
        row["Site Name"]
      end

      duplicate_site_names = site_names.select { |site_name| site_names.count(site_name) > 1 }.uniq

      duplicate_site_names.each do |duplicate_site_name|
        @errors << "Duplicate Site name \"#{duplicate_site_name}\" found in CSV"
      end
    end

    def check_for_ip_range_overlap
      find_ip_range_overlap("RADIUS Clients")
      find_ip_range_overlap("RadSec Clients")
    end

    def find_ip_range_overlap(clients)
      ip_ranges = parsed_csv.map { |row| row[clients]&.split(";") }.flatten

      return unless ip_ranges.any?

      ip_ranges.each do |ip_range_a|
        ip_ranges.each_with_index do |ip_range_b, i|
          next if i == ip_ranges.index(ip_range_a)
          next unless valid_ip_range?(ip_range_b)
          next unless IP::CIDR.new(format_ip_range(ip_range_a)).overlaps?(IP::CIDR.new(format_ip_range(ip_range_b)))

          ip_ranges.delete(ip_range_a)
          @errors << "Overlapping #{clients} IP ranges \"#{ip_range_a}\" - \"#{ip_range_b}\" found in CSV"
        end
      end
    end
  end
end
