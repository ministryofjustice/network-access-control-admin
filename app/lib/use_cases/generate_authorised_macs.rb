class UseCases::GenerateAuthorisedMacs
  def call(mac_authentication_bypasses:)
    bypasses = mac_authentication_bypasses.map do |bypass|
      responses = bypass.responses.map { |response| [response.response_attribute, response.value].join(" = ") }.join(",\n        ")

      bypass.responses.empty? ? bypass.address : [bypass.address, responses].join("\n        ")
    end

    "#{bypasses.join("\n\n")}\n"
  end
end
