module UseCases
  class ConfigValidator
    include RadiusHelper

    def initialize(config_file_path:, content:)
      @config_file_path = config_file_path
      @content = content
    end

    def call
      clean_up_tmp_config_files(config_file_path)
      write_tmp_config_file(config_file_path, content)

      abort("Corrupt FreeRadius configuration: #{parsed_error}") unless configuration_ok?
    ensure
      clean_up_tmp_config_files(config_file_path)
    end

    attr_reader :content, :config_file_path
  end
end
