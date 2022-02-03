def ip_range
  sprintf("%d.%d.%d.%d", rand(256), rand(256), rand(256), rand(256))
end

# def mac_address
#   6.times.map { sprintf("%02x", rand(0..255)) }.join("-")
# end

# p "truncating rules, responses, policies, site policies, mab, clients and sites!"
# base_connection = ActiveRecord::Base.connection

# base_connection.execute("SET FOREIGN_KEY_CHECKS = 0")

# %w[rules responses policies site_policies sites clients mac_authentication_bypasses].each do |table_name|
#   base_connection.truncate(table_name)
# end

# base_connection.execute("SET FOREIGN_KEY_CHECKS = 1")

# p "creating policies"
# 300.times do |p|
#   policy = Policy.create!(name: "Policy: #{p}", description: "Some policy description", fallback: false)

#   policy.rules.create!(request_attribute: "User-Name", operator: "equals", value: "Bob")
#   policy.rules.create!(request_attribute: "3Com-User-Access-Level", operator: "equals", value: "3Com-Visitor")
#   policy.rules.create!(request_attribute: "Zyxel-Callback-Phone-Source", operator: "equals", value: "User")
#   policy.rules.create!(request_attribute: "Aruba-AP-Group", operator: "equals", value: "SetMeUp-C7:7D:EE")
#   policy.rules.create!(request_attribute: "User-Password", operator: "equals", value: "super secure pass")

#   policy.responses.create!(response_attribute: "ARAP-Password", value: "supe secure pass")
#   policy.responses.create!(response_attribute: "Acct-Delay-Time", value: "1234")
#   policy.responses.create!(response_attribute: "Acct-Input-Octets", value: "2323")
#   policy.responses.create!(response_attribute: "EAP-Message", value: "some EAP message")
#   policy.responses.create!(response_attribute: "Reply-Message", value: "Hello there!")
# end

p "creating sites"
750.times do |s|
  site = Site.create!(name: "NEW test site #{s}")
  10.times do |c|
    Client.create!(
      site:,
      ip_range: "#{ip_range}/32",
      shared_secret: "secret#{s}#{c}",
      radsec: false,
    )
  end
end

# p "assigning policies to sites"
# Site.all.each do |site|
#   site.policies << Policy.where(fallback: false).select(:id).sample(5)
# end

# p "creating MABs"
# 15000.times do |m|
#   MacAuthenticationBypass.create!(
#     address: mac_address.to_s,
#     name: "MAB#{m}",
#     description: "MAC Address for #{m}",
#   )
# end

# p "creating certificates"
# 10.times do |c|
#   Certificate.create!(
#     name: "Certificate#{c}",
#     description: "Certificate No. #{c}",
#     subject: "Common-Name=Certificate#{c}",
#     expiry_date: Date.today + 1,
#     category: "EAP",
#     filename: "#{c}.pem",
#   )
# end
