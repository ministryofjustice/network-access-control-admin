module CSVImport
  require "csv"

  class MacAuthenticationBypasses
    attr_accessor :records

    CSV_HEADERS = "Address,Name,Description,Responses,Site".freeze

    include ActiveModel::Validations
    include ActiveModel::Conversion
    include ActiveModel::Naming

    validate :validate_csv
    validate :validate_records
    validate :validate_radius_attributes
    validate :validate_sites

    def initialize(csv_contents = nil)
      @csv_contents = remove_utf8_byte_order_mark(csv_contents) if csv_contents
      @records = []
      @sites_not_found = []
      @all_mac_addresses = MacAuthenticationBypass.all.map(&:address)

      return unless valid_header?

      @records = parse_csv(@csv_contents)
    end

    def save
      return false unless valid?

      records_to_save = []
      responses_to_save = []
      last_id = MacAuthenticationBypass.last&.id || 0
      @records.each_with_index do |record, i|
        record_id = last_id + i + 1
        records_to_save << { id: record_id, address: record.address, name: record.name, description: record.description, site_id: record.site&.id }
        record.responses.each do |response|
          responses_to_save << { mac_authentication_bypass_id: record_id, response_attribute: response.response_attribute, value: response.value }
        end
      end

      MacAuthenticationBypass.insert_all(records_to_save)
      MabResponse.insert_all(responses_to_save)
    end

  private

    def remove_utf8_byte_order_mark(content)
      return content[3..] if "\xEF\xBB\xBFA".force_encoding("ASCII-8BIT") == content[0..3]

      content
    end

    def parse_csv(csv_contents)
      all_sites = Site.all
      records = []

      CSV.parse(csv_contents, headers: true).each do |row|
        address = row["Address"]
        name = row["Name"]
        description = row["Description"]
        responses = row["Responses"]
        site_name = row["Site"]

        site = all_sites.detect { |s| s.name == site_name }

        if site_name.present? && site.nil?
          @sites_not_found << site_name
        end

        record = CSVImport::MacAuthenticationBypass.new(
          name: name,
          address: address,
          description: description,
          site: site,
        )

        @all_mac_addresses << address

        unwrap_responses(responses).each do |response|
          record.responses << response
        end

        records << record
      end

      records
    end

    def validate_csv
      return errors.add(:base, "CSV is missing") if @csv_contents.nil?

      errors.add(:base, "The CSV header is invalid") unless valid_header?
    end

    def validate_records
      @records.each_with_index do |record, i|
        record.validate
        record.validate_uniqueness_of_address(@all_mac_addresses)

        record.errors.full_messages.each do |message|
          errors.add(:base, "Error on row #{i + 2}: #{message}")
        end

        record.responses.each do |response|
          response.errors.full_messages.each do |message|
            errors.add(:base, "Error on row #{i + 2}: #{message}")
          end
        end
      end
    end

    def validate_sites
      @sites_not_found.each do |site_name|
        errors.add(:base, "Site \"#{site_name}\" is not found")
      end
    end

    def validate_radius_attributes
      UseCases::ValidateRadiusAttributes.new(records: @records, errors: errors).call
    end

    def unwrap_responses(responses)
      responses.to_s.split(";").map do |r|
        response_attribute, value = r.split("=")
        CSVImport::MabResponse.new(response_attribute: response_attribute, value: value)
      end
    end

    def valid_header?
      @csv_contents.to_s.lines.first&.strip == CSV_HEADERS
    end
  end
end
