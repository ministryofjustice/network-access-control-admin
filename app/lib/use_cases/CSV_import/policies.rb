module UseCases
  require "csv"

  class CSVImport::Policies < CSVImport::Base
    def save
      map_csv_content

      @records.each(&:save)
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
  end
end
