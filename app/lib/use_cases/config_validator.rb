module UseCases
  class ConfigValidator
    def initialize(config_file_path:, content:)
      @config_file_path = config_file_path
      @content = content
    end

    def call
      clean_up_tmp_config_files
      write_tmp_config_file

      abort("Corrupt FreeRadius configuration: #{parsed_error}") unless configuration_ok?
    ensure
      clean_up_tmp_config_files
    end

  private

    def write_tmp_config_file
      File.write(config_file_path, content)
    end

    def clean_up_tmp_config_files
      ["/etc/raddb/clients.conf", "/etc/raddb/mods-config/files/authorize", config_file_path].each { |f| File.write(f, "") }
    end

    def result
      @result ||= `/usr/sbin/radiusd -CX`
    end

    def parsed_error
      result.split("\n").last(5).join("\n")
    end

    def configuration_ok?
      result.match?(/Configuration appears to be OK/)
    end

    attr_reader :content, :config_file_path
  end
end
