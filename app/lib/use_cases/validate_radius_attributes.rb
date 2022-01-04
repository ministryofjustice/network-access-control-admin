module UseCases
  class ValidateRadiusAttributes < UseCases::ConfigValidator
    def initialize(records:, errors:)
      @records = records
      @errors = errors
      @config_file_path = "/etc/raddb/mods-config/files/authorize"
      @content = UseCases::GenerateAuthorisedMacs.new.call(mac_authentication_bypasses: @records)
    end

    def call
      clean_up_tmp_config_files
      write_tmp_config_file

      return if configuration_ok?

      @records.each_with_index do |record, i|
        error_line = parsed_error.split("\n").select { |l| l.include?(record.address) }[0]
        if error_line
          message = error_line.match(/#{record.address}: (.*)/)[1]
          @errors.add(:base, "Error on row #{i + 2}: #{message}")
        end
      end
    end
  end
end
