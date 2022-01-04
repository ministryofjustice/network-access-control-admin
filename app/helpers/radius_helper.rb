module RadiusHelper
  def write_tmp_config_file(config_file_path, content)
    File.write(config_file_path, content)
  end

  def clean_up_tmp_config_files(config_file_path)
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
end
