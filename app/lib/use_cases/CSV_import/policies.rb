module UseCases
  require "csv"

  class CSVImport::Policies < CSVImport::Base
    CSV_HEADERS = "Name,Description,Rules,Responses".freeze
    def save
      return { errors: @errors } unless valid_csv?

      map_csv_content

      @records.each(&:save)

      { errors: [] }
    end

    def map_csv_content
      parsed_csv.each do |row|
        name = row["Name"]
        description = row["Description"]
        rules = row["Rules"]
        responses = row["Responses"]

        record = Policy.new(
          name:,
          description:,
        )

        unwrap_rules(rules).each do |rule|
          record.rules << rule
        end

        unwrap_responses(responses).each do |response|
          record.responses << response
        end

        @records << record
      end
    end

    def unwrap_rules(rules)
      rules.to_s.split(";").map do |r|
        if r.include?("=~")
          operator = "contains"
          request_attribute, value = r.split("=~")
        else
          operator = "equals"
          request_attribute, value = r.split("=")
        end
        Rule.new(request_attribute:, operator:, value:)
      end
    end

    def valid_csv?
      return @errors << "CSV is missing" && false if @csv_contents.nil?
      return @errors << "The file extension is invalid" && false unless valid_file_extension?
      return @errors << "The CSV header is invalid" && false unless valid_header?(CSV_HEADERS)
      return @errors << "There is no data to be imported" && false unless @csv_contents.split("\n").second

      @errors.empty?
    end
  end
end
