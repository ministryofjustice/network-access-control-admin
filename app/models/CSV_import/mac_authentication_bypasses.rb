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
    validate :validate_sites

    def initialize(csv_contents = nil)
      @csv_contents = remove_utf8_byte_order_mark(csv_contents) if csv_contents
      @records = []
      @sites_not_found = []

      return unless valid_header?

      @records = parse_csv(@csv_contents)
    end

    def save
      return false unless valid?

      @records.each(&:save)
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

    def validate_csv
      return errors.add(:base, "CSV is missing") if @csv_contents.nil?
      return errors.add(:base, "There is no data to be imported") unless @csv_contents.split("\n").second

      errors.add(:base, "The CSV header is invalid") unless valid_header?
    end

    def validate_records
      @records.each.with_index(2) do |record, i|
        record.validate

        record.errors.full_messages.each do |message|
          errors.add(:base, "Error on row #{i}: #{message}")
        end

        record.responses.each do |response|
          response.errors.full_messages.each do |message|
            errors.add(:base, "Error on row #{i}: #{message}")
          end
        end
      end
    end

    def validate_sites
      @sites_not_found.each do |site_name|
        errors.add(:base, "Site \"#{site_name}\" is not found")
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
