module UseCases
  class ValidateRadiusAttributes
    include RadiusHelper

    attr_reader :content, :config_file_path

    def initialize(records:, errors:)
      @records = records
      @errors = errors
      @config_file_path = AUTHORISED_MACS_PATH
      @content = UseCases::GenerateAuthorisedMacs.new.call(mac_authentication_bypasses: @records)
    end

    def call
      clean_up_tmp_config_files(config_file_path)
      write_tmp_config_file(config_file_path, content)

      return if configuration_ok?

      @records.each_with_index do |record, i|
        error_line = parsed_error.split("\n").select { |l| l.include?(record.address) }[0]
        if error_line
          message = error_line.match(/#{record.address}: (.*)/)[1]
          @errors.add(:base, "Error on row #{i + 2}: #{message}")
        end
      end
    ensure
      clean_up_tmp_config_files(config_file_path)
    end
  end
end
