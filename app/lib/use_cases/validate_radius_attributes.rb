module UseCases
  class ValidateRadiusAttributes
    def initialize(records:, errors:)
      @records = records
      @errors = errors
    end

    def call
      content = UseCases::GenerateAuthorisedMacs.new.call(mac_authentication_bypasses: @records)

      radius_errors = ""

      UseCases::ConfigValidator.new(
        config_file_path: "/etc/raddb/mods-config/files/authorize",
        content: content,
      ).call do |error|
        radius_errors = error
      end

      @records.each_with_index do |record, i|
        error_line = radius_errors.split("\n").select { |l| l.include?(record.address) }[0]
        if error_line
          message = error_line.match(/#{record.address}: (.*)/)[1]
          @errors.add(:base, "Error on row #{i + 2}: #{message}")
        end
      end
    end
  end
end
