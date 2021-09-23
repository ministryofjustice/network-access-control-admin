def ip_range
  "%d.%d.%d.%d" % [rand(256), rand(256), rand(256), rand(256)]
end

2000.times do |s|
  site = Site.create!(name: "Test site #{s}")

  fallback_policy = Policy.create!(
    name: "Fallback Policy: #{s}",
    description: "Some policy description",
    fallback: true
  )

  fallback_response = Response.create!(
    response_attribute: "Reply-Message",
    value: "Oh no"
  )

  fallback_policy.responses << fallback_response

  5.times do |p|
    policy = Policy.create!(
      name: "Policy: #{p} #{s}",
      description: "Some policy description",
      fallback: false,
    )

    5.times do |r|
      policy.rules.create!(
        request_attribute: "Aruba-AP-Group",
        operator: "equals",
        value: "SetMeUp-C7:7D:EE"
      )
    end

    5.times do |r|
      policy.responses.create!(
        response_attribute: "Reply-Message",
        value: "Hello! #{r} #{s}"
      )
    end

    site.policies << policy
    site.policies << fallback_policy
  end

  20.times do |c|
    begin
      Client.create!(
        site: site,
        ip_range: "#{ip_range}/32",
        shared_secret: "secret#{s}#{c}",
      )
    rescue
      retry
    end
  end
end
