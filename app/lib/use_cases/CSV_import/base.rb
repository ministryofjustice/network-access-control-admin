module UseCases
  class CSVImport::Base
    def initialize(csv_contents = nil)
      @csv_contents = remove_utf8_byte_order_mark(csv_contents&.fetch(:contents)) if csv_contents&.fetch(:contents)
      @filename = csv_contents&.fetch(:filename)
      @records = []
      @errors = []
    end

    def call
      return { errors: @errors } unless valid_csv?

      map_csv_content

      return { errors: @errors } unless valid_records?

      @records.each(&:save)

      { errors: [] }
    end

  private

    def parsed_csv
      @parsed_csv ||= CSV.parse(@csv_contents, skip_blanks: true, headers: true)
    end

    def remove_utf8_byte_order_mark(content)
      return content[3..].force_encoding("UTF-8") if content[0..3].include?("\xEF\xBB\xBF".force_encoding("ASCII-8BIT"))

      content.force_encoding("UTF-8")
    end

    def unwrap_responses(responses)
      responses.to_s.split(";").map do |r|
        response_attribute, value = r.split("=")
        Response.new(response_attribute:, value:)
      end
    end

    def valid_file_extension?
      File.extname(@filename) == ".csv"
    end

    def valid_header?(csv_headers)
      return false unless @csv_contents.to_s.lines.first&.valid_encoding?

      @csv_contents.to_s.lines.first&.strip == csv_headers
    end

    def valid_records?
      validate_records

      @errors.empty?
    end

    def check_for_duplicate_response_attributes(column)
      responses = parsed_csv.map { |row| row[column] }.compact
      response_attributes = responses.map { |line| line.split("\;").map { |att| att.split("=").first } }

      response_attributes.each.with_index(2) do |line, i|
        duplicate_response_attribute = line.select { |attribute| line.count(attribute) > 1 }.uniq

        duplicate_response_attribute.each do |duplicate_attr|
          @errors << "Error on row #{i}: Duplicate response attribute \"#{duplicate_attr}\" found in CSV"
        end
      end
    end
  end
end
