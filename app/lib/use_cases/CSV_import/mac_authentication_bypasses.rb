module UseCases
  require "csv"

  class CSVImport::MacAuthenticationBypasses < CSVImport::Base
    CSV_HEADERS = "Address,Name,Description,Responses,Site".freeze

  private

    def map_csv_content
      @sites_not_found = []
      all_sites = Site.all

      parsed_csv.each do |row|
        address = row["Address"]
        name = row["Name"]
        description = row["Description"]
        responses = row["Responses"]
        site_name = row["Site"]

        site = all_sites.detect { |s| s.name == site_name }

        if site_name.present? && site.nil?
          @sites_not_found << site_name
        end

        record = MacAuthenticationBypass.new(
          name:,
          address:,
          description:,
          site:,
        )

        unwrap_responses(responses).each do |response|
          record.responses << response
        end

        @records << record
      end
    end

    def check_for_duplicate_mac_addresses
      addresses = parsed_csv.map do |row|
        row["Address"]
      end

      duplicate_addresses = addresses.select { |address| addresses.count(address) > 1 }.uniq

      duplicate_addresses.each do |duplicate_address|
        @errors << "Duplicate MAC Address \"#{duplicate_address}\" found in CSV"
      end
    end

    def valid_csv?
      return @errors << "CSV is missing" && false if @csv_contents.nil?
      return @errors << "The file extension is invalid" && false unless valid_file_extension?
      return @errors << "The CSV header is invalid" && false unless valid_header?(CSV_HEADERS)
      return @errors << "There is no data to be imported" && false unless @csv_contents.split("\n").second

      check_for_duplicate_mac_addresses
      check_for_duplicate_attributes("Responses")

      @errors.empty?
    end

    def validate_records
      @records.each.with_index(2) do |record, row|
        record.validate

        record.errors.full_messages.each do |message|
          @errors << "Error on row #{row}: #{message}"
        end

        fetch_validation_errors(record.responses, row)
      end

      @sites_not_found.each do |site_name|
        @errors << "Site \"#{site_name}\" is not found"
      end
    end
  end
end
