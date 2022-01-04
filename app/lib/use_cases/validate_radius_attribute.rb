module UseCases
  class ValidateRadiusAttribute
    include RadiusHelper

    def call(attribute:, value:)
      write_tmp_config_file(AUTHORISED_MACS_PATH, mab_content(attribute, value))

      result = error_from_logs(boot_freeradius_to_validate_attributes)

      result_payload(result, attribute, value)
    end

  private

    def mab_content(attribute, value)
      <<~HEREDOC
        aa-bb-cc-77-88-99
        \t#{attribute} = "#{value}"
      HEREDOC
    end

    def error_from_logs(output)
      output.split("\n").select { |l| l.include?("error") }[0]
    end

    def result_payload(result, _attribute, _value)
      return { success: true, message: "" } if result.nil?

      { success: false, message: result.match(/aa-bb-cc-77-88-99: (.*)/)[1] }
    end
  end
end
