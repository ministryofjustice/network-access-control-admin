module RadiusHelper
  AUTHORISED_MACS_PATH = "/etc/raddb/mods-config/files/authorize".freeze
  AUTHORISED_CLIENTS_PATH = "/etc/raddb/clients.conf".freeze

  def write_tmp_config_file(config_file_path, content)
    File.write(config_file_path, content)
  end

  def clean_up_tmp_config_files(config_file_path)
    [AUTHORISED_CLIENTS_PATH, AUTHORISED_MACS_PATH, config_file_path].each { |f| File.write(f, "") }
  end

  def boot_freeradius_to_validate_attributes
    `/usr/sbin/radiusd -CX`
  end

  def parsed_error
    boot_freeradius_to_validate_attributes.split("\n").last(5).join("\n")
  end

  def configuration_ok?
    boot_freeradius_to_validate_attributes.match?(/Configuration appears to be OK/)
  end
end
