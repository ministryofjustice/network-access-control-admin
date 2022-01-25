module UseCases
  class CSVImport::AuditMacAuthenticationBypassesImport
    def initialize(current_user)
      @current_user = current_user
    end

    def call(records)
      audits_to_save = []

      records.each do |record|
        mac_authentication_bypass = { address: record.address, name: record.name, description: record.description, site_id: record.site_id }

        audits_to_save << {
          auditable_id: record.id,
          action: "create",
          audited_changes: mac_authentication_bypass,
          auditable_type: "MacAuthenticationBypass",
          user_id: @current_user.id,
          user_type: "User",
        }

        record.responses.each do |response|
          mab_response = { mac_authentication_bypass_id: record.id, response_attribute: response.response_attribute, value: response.value }

          audits_to_save << {
            auditable_id: response.id,
            action: "create",
            audited_changes: mab_response,
            auditable_type: "Response",
            user_id: @current_user.id,
            user_type: "User",
          }
        end
      end

      Audit.insert_all(audits_to_save)
    end
  end
end
