module CSVImport
  class SitesWithClients
    include ActiveModel::Validations

    attr_accessor :records

    validate :validate_csv_format
    validate :validate_records

    def initialize(parse_csv)
      parsed_records = parse_csv.call

      @records = parsed_records[:records]
      @csv_parse_errors = parsed_records[:errors]
    end

    def save
      return false unless valid?

      sites_to_save = []
      clients_to_save = []
      fallback_policies_to_save = []
      fallback_policy_responses_to_save = []
      site_policies_to_save = []

      @records.each do |site|
        sites_to_save << { id: site.id, name: site.name, tag: site.name.parameterize(separator: "_"), policy_count: site.policies.to_a.count }

        site.clients.each do |client|
          client.valid?
          clients_to_save << { ip_range: client.ip_range, shared_secret: client.shared_secret, site_id: site.id, radsec: client.radsec }
        end

        site.policies.each do |policy|
          if policy.fallback?
            fallback_policies_to_save << {
              name: policy.name,
              description: policy.description,
              fallback: policy.fallback,
              rule_count: policy.rule_count,
              site_count: 1,
            }

            policy.responses.each do |response|
              fallback_policy_responses_to_save << { policy_id: policy.id, response_attribute: response.response_attribute, value: response.value }
            end
          end

          site_policies_to_save << { site_id: site.id, policy_id: policy.id }
        end
      end

      ActiveRecord::Base.transaction do
        Site.insert_all(sites_to_save)
        Client.insert_all(clients_to_save)
        Policy.insert_all(fallback_policies_to_save)
        PolicyResponse.insert_all(fallback_policy_responses_to_save)
        SitePolicy.insert_all(site_policies_to_save)
      end
    end

  private

    def validate_csv_format
      return unless @csv_parse_errors.present?

      @csv_parse_errors.each do |error|
        errors.add(:base, error)
      end
    end

    def validate_records
      return unless @records

      site_names = Site.pluck(:name)
      eap_ip_ranges = Client.where(radsec: false).pluck(:ip_range)
      radsec_ip_ranges = Client.where(radsec: true).pluck(:ip_range)

      @records.each.with_index(2) do |record, row|
        record.validate

        validate_uniqueness_of_site_name(record.name, site_names, row)
        validate_ip_ranges(record.clients.reject(&:radsec), eap_ip_ranges, row)
        validate_ip_ranges(record.clients.select(&:radsec), radsec_ip_ranges, row)

        record.errors.full_messages.each do |error|
          errors.add(:base, "Error on row #{row}: Site #{error}")
        end

        record.clients.each do |client|
          client.errors.full_messages.each do |client_error|
            errors.add(:base, "Error on row #{row}: Client #{client_error}")
          end
        end

        fallback_policy = record.policies.first

        fallback_policy.errors.full_messages.each do |fallback_policy_error|
          errors.add(:base, "Error on row #{row}: Fallback Policy #{fallback_policy_error}")
        end

        fallback_policy.responses.each do |response|
          response.errors.full_messages.each do |response_error|
            errors.add(:base, "Error on row #{row}: #{response_error}")
          end
        end
      end
    end

    def validate_ip_ranges(clients, ip_ranges, row)
      clients.each do |client|
        if ip_ranges.include?(client.ip_range)
          return errors.add(:base, "Error on row #{row}: Client Ip range has already been taken")
        elsif ip_range_overaps?(client.ip_range, ip_ranges)
          return errors.add(:base, "Error on row #{row}: IP overlaps with another IP range - #{client.ip_range}")
        else
          ip_ranges << client.ip_range
        end
      end
    end

    def ip_range_overaps?(ip_range, existing_ip_ranges)
      existing_ip_ranges.each do |existing_ip_range|
        next unless IP::CIDR.new(ip_range).overlaps?(IP::CIDR.new(existing_ip_range))

        return true
      end

      false
    end

    def validate_uniqueness_of_site_name(site_name, existing_site_names, row)
      if existing_site_names.include?(site_name)
        errors.add(:base, "Error on row #{row}: Site Name has already been taken")
      else
        existing_site_names << site_name
      end
    end
  end
end
