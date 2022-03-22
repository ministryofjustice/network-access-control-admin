class SeedNacs
  def run
    # truncate(%w[responses policies site_policies sites clients mac_authentication_bypasses])
    # ensure_mac_addresses_belong_to_sites
    truncate(%w[responses mac_authentication_bypasses])
    # create_policies
    # create_sites
    # assign_policies_to_sites
    # create_mabs
    # create_certificates
  end

private

  def ensure_mac_addresses_belong_to_sites
    MacAuthenticationBypass.where(site: nil).each do |bypass|
      bypass.site = Site.first
      bypass.save!
    end
  end

  def ip_range
    sprintf("%d.%d.%d.%d", rand(256), rand(256), rand(256), rand(256))
  end

  def mac_address
    6.times.map { sprintf("%02x", rand(0..255)) }.join("-")
  end

  def truncate(tables)
    p "truncating #{tables.join(' ')}"

    base_connection = ActiveRecord::Base.connection
    base_connection.execute("SET FOREIGN_KEY_CHECKS = 0")
    tables.each { |table_name| base_connection.truncate(table_name) }
    base_connection.execute("SET FOREIGN_KEY_CHECKS = 1")
  end

  def create_policies
    p "creating policies"

    300.times do |p|
      policy = Policy.create!(name: "Policy: #{p}", description: "Some policy description", fallback: false)

      policy.rules.create!(request_attribute: "User-Name", operator: "equals", value: "Bob")
      policy.rules.create!(request_attribute: "3Com-User-Access-Level", operator: "equals", value: "3Com-Visitor")
      policy.rules.create!(request_attribute: "Zyxel-Callback-Phone-Source", operator: "equals", value: "User")
      policy.rules.create!(request_attribute: "Aruba-AP-Group", operator: "equals", value: "SetMeUp-C7:7D:EE")
      policy.rules.create!(request_attribute: "User-Password", operator: "equals", value: "super secure pass")

      policy.responses.create!(response_attribute: "ARAP-Password", value: "supe secure pass")
      policy.responses.create!(response_attribute: "Acct-Delay-Time", value: "1234")
      policy.responses.create!(response_attribute: "Acct-Input-Octets", value: "2323")
      policy.responses.create!(response_attribute: "EAP-Message", value: "some EAP message")
      policy.responses.create!(response_attribute: "Reply-Message", value: "Hello there!")
    end
  end

  def create_sites
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
  end

  def assign_policies_to_sites
    p "assigning policies to sites"
    Site.all.each do |site|
      site.policies << Policy.where(fallback: false).select(:id).sample(5)
    end
  end

  def create_mabs
    p "creating MABs"

    100_000.times do |m|
      MacAuthenticationBypass.create!(
        address: mac_address,
        name: "Performance testing #{m}",
        description: "MAC Address Testing #{m}",
        responses: [
          MabResponse.create!(
            response_attribute: "Tunnel-Type",
            value: "VLAN",
          ),
          MabResponse.create!(
            response_attribute: "Tunnel-Medium-Type",
            value: "IEEE-802",
          ),
          MabResponse.create!(
            response_attribute: "Tunnel-Private-Group-Id",
            value: "777",
          ),
        ],
      )
    end
  end

  def create_certificates
    p "creating certificates"

    10.times do |c|
      Certificate.create!(
        name: "Certificate#{c}",
        description: "Certificate No. #{c}",
        subject: "Common-Name=Certificate#{c}",
        expiry_date: Date.today + 1,
        category: "EAP",
        filename: "#{c}.pem",
      )
    end
  end
end

SeedNacs.new.run
