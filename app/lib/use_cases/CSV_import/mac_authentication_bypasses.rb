module UseCases
  require "csv"

  class CSVImport::MacAuthenticationBypasses
    CSV_HEADERS = "Address,Name,Description,Responses,Site".freeze

    def initialize(csv_contents = nil)
      @csv_contents = remove_utf8_byte_order_mark(csv_contents) if csv_contents
      @records = []
      @errors = []
      @sites_not_found = []

      return unless valid_header?

      @records = save_csv
    end

    def save
      return { errors: @errors } unless valid?

      @records.each(&:save)

      { errors: [] }
    end

    def valid?
      validate_csv
      validate_records
      validate_sites

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

    def save_csv
      all_sites = Site.all
      records = []

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
          name: name,
          address: address,
          description: description,
          site: site,
        )

        unwrap_responses(responses).each do |response|
          record.responses << response
        end

        records << record
      end

      records
    end

    def check_for_duplicates_in_csv
      addresses = parsed_csv.map do |row|
        row["Address"]
      end

      duplicate_addresses = addresses.select { |address| addresses.count(address) > 1 }.uniq

      duplicate_addresses.each do |duplicate_address|
        @errors << "Duplicate MAC address #{duplicate_address} found in CSV"
      end
    end

    def validate_csv
      return @errors << "CSV is missing" if @csv_contents.nil?
      return @errors << "There is no data to be imported" unless @csv_contents.split("\n").second

      check_for_duplicates_in_csv

      @errors << "The CSV header is invalid" unless valid_header?
    end

    def validate_records
      @records.each.with_index(2) do |record, i|
        record.validate

        record.errors.full_messages.each do |message|
          @errors << "Error on row #{i}: #{message}"
        end

        record.responses.each do |response|
          response.errors.full_messages.each do |message|
            @errors << "Error on row #{i}: #{message}"
          end
        end
      end
    end

    def validate_sites
      @sites_not_found.each do |site_name|
        @errors << "Site \"#{site_name}\" is not found"
      end
    end

    def unwrap_responses(responses)
      responses.to_s.split(";").map do |r|
        response_attribute, value = r.split("=")
        MabResponse.new(response_attribute: response_attribute, value: value)
      end
    end

    def valid_header?
      @csv_contents.to_s.lines.first&.strip == CSV_HEADERS
    end
  end
end
