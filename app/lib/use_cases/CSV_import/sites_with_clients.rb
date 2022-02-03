module UseCases
  require "csv"

  class CSVImport::SitesWithClients
    CSV_HEADERS = "Site Name,EAP Clients,RadSec Clients,Policies,Fallback Policy".freeze

    def initialize(csv_contents = nil)
      @csv_contents = remove_utf8_byte_order_mark(csv_contents) if csv_contents
      @records = []
      @errors = []
    end

    def save
      return { errors: @errors } unless valid_csv?

      map_csv_content

      return { errors: @errors } unless valid_records?

      @records.each(&:save)

      { errors: [] }
    end

    def valid_records?
      validate_records

      @errors.empty?
    end

  private
    def remove_utf8_byte_order_mark(content)
      return content[3..] if "\xEF\xBB\xBFA".force_encoding("ASCII-8BIT") == content[0..3]

      content
    end

    def parsed_csv
      @parsed_csv ||= CSV.parse(@csv_contents, skip_blanks: true, headers: true)
    end

    def map_csv_content
      site_names = Site.pluck(:name)
      eap_ip_ranges = Client.where(radsec: false).pluck(:ip_range)
      radsec_ip_ranges = Client.where(radsec: true).pluck(:ip_range)

      @records = parsed_csv.map do |row|
        site_name = row["Site Name"]
        eap_clients = row["EAP Clients"]
        radsec_clients = row["RadSec Clients"]
        policies = row["Policies"]
        fallback_policy = row["Fallback Policy"]

        record = CSVImport::Site.new(
          name: site_name,
        )

        # record.policies << CSVImport::Policy.new(
        #   name: "Fallback policy for #{site_name}",
        #   description: "Default fallback policy for #{site_name}",
        #   fallback: true,
        # )

        # unwrap_responses(fallback_policy).each do |fallback_policy_response|
        #   record.policies.first.responses << fallback_policy_response
        # end

        # assign_policies(policies, all_policies, record, i + 1)

        # map_clients(eap_clients, radsec_clients, record)

        record
      end
    end

    def valid_csv?
      return @errors << "CSV is missing" && false if @csv_contents.nil?
      return @errors << "The CSV header is invalid" && false unless valid_header?
      return @errors << "There is no data to be imported" && false unless @csv_contents.split("\n").second

      @errors.empty?
    end

    def valid_header?
      @csv_contents.to_s.lines.first&.strip == CSV_HEADERS
    end

    def validate_records
      return unless @records

      site_names = Site.pluck(:name)
      eap_ip_ranges = Client.where(radsec: false).pluck(:ip_range)
      radsec_ip_ranges = Client.where(radsec: true).pluck(:ip_range)

      @records.each.with_index(2) do |record, row|
        record.validate

        validate_uniqueness_of_site_name(record.name, site_names, row)
        validate_ip_ranges(record.clients.reject(&:radsec), eap_ip_ranges, row)
        validate_ip_ranges(record.clients.select(&:radsec), radsec_ip_ranges, row)

        record.errors.full_messages.each do |error|
          errors.add(:base, "Error on row #{row}: Site #{error}")
        end

        record.clients.each do |client|
          client.errors.full_messages.each do |client_error|
            errors.add(:base, "Error on row #{row}: Client #{client_error}")
          end
        end

        fallback_policy = record.policies.first

        fallback_policy.errors.full_messages.each do |fallback_policy_error|
          errors.add(:base, "Error on row #{row}: Fallback Policy #{fallback_policy_error}")
        end

        fallback_policy.responses.each do |response|
          response.errors.full_messages.each do |response_error|
            errors.add(:base, "Error on row #{row}: #{response_error}")
          end
        end
      end
    end

    def validate_ip_ranges(clients, ip_ranges, row)
      clients.each do |client|
        if ip_ranges.include?(client.ip_range)
          return errors.add(:base, "Error on row #{row}: Client Ip range has already been taken")
        elsif ip_range_overaps?(client.ip_range, ip_ranges)
          return errors.add(:base, "Error on row #{row}: IP overlaps with another IP range - #{client.ip_range}")
        else
          ip_ranges << client.ip_range
        end
      end
    end

    def ip_range_overaps?(ip_range, existing_ip_ranges)
      existing_ip_ranges.each do |existing_ip_range|
        next unless IP::CIDR.new(ip_range).overlaps?(IP::CIDR.new(existing_ip_range))

        return true
      end

      false
    end

    def validate_uniqueness_of_site_name(site_name, existing_site_names, row)
      if existing_site_names.include?(site_name)
        errors.add(:base, "Error on row #{row}: Site Name has already been taken")
      else
        existing_site_names << site_name
      end
    end
  end
end
