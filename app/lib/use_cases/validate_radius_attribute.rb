module UseCases
  class ValidateRadiusAttribute
    include RadiusHelper

    DEFAULT_SITE_PATH = "/etc/raddb/sites-enabled/default".freeze

    def call(attribute:, value:, operator: nil)
      clean_up_tmp_config_files(DEFAULT_SITE_PATH)

      write_tmp_config_file(DEFAULT_SITE_PATH, test_config(attribute, value, operator))
      payload(error_from_logs(boot_freeradius_to_validate_attributes), attribute, value)
    ensure
      clean_up_tmp_config_files(DEFAULT_SITE_PATH)
    end

  private

    def test_config(attribute, value, operator)
      operator.present? ? rule_config(attribute, value, operator) : response_config(attribute, value)
    end

    def rule_config(attribute, value, operator)
      test_operator = operator == "equals" ? "==" : "=~"
      test_value = operator == "equals" ? "\"#{value}\"" : "/#{value}/"

      <<~HEREDOC
        server test_config {
          authorize {
            if ( #{attribute} #{test_operator} #{test_value} ) {
              ok = 1
            }
          }
        }
      HEREDOC
    end

    def response_config(attribute, value)
      <<~HEREDOC
        server test_config {
          authorize {
            update reply {
              #{attribute} = \"#{value}\"
            }
          }
        }
      HEREDOC
    end

    def error_from_logs(output)
      output.match(/\/etc\/raddb\/sites-enabled\/default\[\d\]:(.*)/)

      Regexp.last_match(1).to_s.strip
    end

    def payload(result, _attribute, _value)
      return { success: true, message: "" } if configuration_ok?

      { success: false, message: result }
    end
  end
end
