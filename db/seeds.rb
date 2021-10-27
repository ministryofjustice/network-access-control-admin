def ip_range
  sprintf("%d.%d.%d.%d", rand(256), rand(256), rand(256), rand(256))
end

def mac_address
  6.times.map { sprintf("%02x", rand(0..255)) }.join("-")
end

p "creating policies"
3000.times do |p|
  policy = Policy.create!(name: "Policy: #{p}", description: "Some policy description", fallback: false)

  5.times do |r|
    policy.rules.create!(request_attribute: "Aruba-AP-Group", operator: "equals", value: "SetMeUp-C7:7D:EE#{p}-#{r}")
  end

  5.times do |r|
    policy.responses.create!(response_attribute: "Reply-Message", value: "Hello! #{r} #{p}")
  end
end

p "creating policies"
500.times do |s|
  fallback_policy = Policy.create!(name: "Fallback Policy: #{s}", description: "Some policy description", fallback: true)
  fallback_response = Response.create!(response_attribute: "Reply-Message", value: "Oh no #{s}")
  fallback_policy.responses << fallback_response
end

p "creating sites"
2000.times do |s|
  site = Site.create!(name: "Test site #{s}")

  20.times do |c|
    Client.create!(
      site: site,
      ip_range: "#{ip_range}/32",
      shared_secret: "secret#{s}#{c}",
    )
  rescue StandardError
    retry
  end
end

p "assigning policies to sites"
Site.all.each do |site|
  site.policies << Policy.select(:id).sample(5)
  site.policies << Policy.where(fallback: true).select(:id).sample
end

p "creating MABs"
100.times do |m|
  MacAuthenticationBypass.create!(
    address: mac_address.to_s,
    name: "MAB#{m}",
    description: "MAC Address for #{m}",
  )
end
