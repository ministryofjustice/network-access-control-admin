module UseCases
  class ValidateRadiusAttribute
    def call(attribute:, value:)
      generate_test_authorised_macs_file(mab_content(attribute, value))
      result = error_from_logs(boot_freeradius_to_validate_authorised_macs_file)

      result_payload(result, attribute, value)
    end

  private

    def generate_test_authorised_macs_file(content)
      File.write("/etc/raddb/mods-config/files/authorize", content)
    end

    def mab_content(attribute, value)
      <<~HEREDOC
        aa-bb-cc-77-88-99
        \t#{attribute} = "#{value}"
      HEREDOC
    end

    def boot_freeradius_to_validate_authorised_macs_file
      `/usr/sbin/radiusd -xx -l stdout`
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