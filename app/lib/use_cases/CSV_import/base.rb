module UseCases
  class CSVImport::Base
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

    def parsed_csv
      @parsed_csv ||= CSV.parse(@csv_contents, skip_blanks: true, headers: true)
    end

    def remove_utf8_byte_order_mark(content)
      return content[3..].force_encoding("UTF-8") if content[0..3].include?("\xEF\xBB\xBF".force_encoding("ASCII-8BIT"))

      content.force_encoding("UTF-8")
    end

    def unwrap_responses(fallback_policy_responses)
      fallback_policy_responses.to_s.split(";").map do |r|
        response_attribute, value = r.split("=")
        Response.new(response_attribute:, value:)
      end
    end

    def valid_header?(csv_headers)
      @csv_contents.to_s.lines.first&.strip == csv_headers
    end
  end
end
