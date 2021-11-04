contents = <<~HEREDOC
  aa-bb-cc-77-88-99
  \tTUNNEL-TYPE = "VLANs"
HEREDOC

File.write("/etc/raddb/mods-config/files/authorize", contents)

result = `/usr/sbin/radiusd -xx -l stdout`

p result.split("\n").select { |l| l.include?("error") }[0]
