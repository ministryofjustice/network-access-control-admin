module UseCases
  require "csv"

  class CSVImport::SitesWithClients < CSVImport::Base
    include ApplicationRecordHelper

    CSV_HEADERS = "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy".freeze

    def valid_records?
      validate_records

      @errors.empty?
    end

  private

    def map_csv_content
      @records = parsed_csv.map.with_index(1) do |row, i|
        site_name = row["Site Name"]
        eap_clients = row["EAP Clients"]
        radsec_clients = row["RadSec Clients"]
        policies = row["Policies"]
        fallback_policy = row["Fallback Policy"]

        record = Site.new(
          name: site_name,
        )

        record.policies << Policy.new(
          name: "Fallback policy for #{site_name}",
          description: "Default fallback policy for #{site_name}",
          fallback: true,
        )

        unwrap_responses(fallback_policy).each do |fallback_policy_response|
          record.policies.first.responses << fallback_policy_response
        end

        assign_policies(policies, record, i)
        map_clients(eap_clients, radsec_clients, record)

        record
      end
    end

    def valid_csv?
      start_time = Time.now
      pp "Start validating CSV format#{start_time}"
      return @errors << "CSV is missing" && false if @csv_contents.nil?
      return @errors << "The CSV header is invalid" && false unless valid_header?(CSV_HEADERS)
      return @errors << "There is no data to be imported" && false unless @csv_contents.split("\n").second

      check_for_duplicate_site_names
      check_for_duplicate_response_attributes("Fallback Policy")
      check_for_ip_range_overlap

      pp "Completed validating CSV format in #{Time.now - start_time}"
      @errors.empty?
    end

    def validate_records
      start_time = Time.now
      pp "Start validating records#{start_time}"

      @records.each.with_index(2) do |record, row|
        pp "Validating record: #{record} in row: #{row}"
        record.validate

        record.errors.full_messages.each do |error|
          @errors << "Error on row #{row}: Site #{error}"
        end

        record.clients.each do |client|
          client.errors.full_messages.each do |client_error|
            @errors << "Error on row #{row}: Client #{client_error}"
          end
        end

        fallback_policy = record.policies.first

        fallback_policy.errors.full_messages.each do |fallback_policy_error|
          @errors << "Error on row #{row}: Fallback Policy #{fallback_policy_error}"
        end

        fallback_policy.responses.each do |response|
          response.errors.full_messages.each do |response_error|
            @errors << "Error on row #{row}: #{response_error}"
          end
        end
      end

      pp "Completed validating records in #{Time.now - start_time}"
      @errors.empty?
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
      find_ip_range_overlap("EAP Clients")
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
