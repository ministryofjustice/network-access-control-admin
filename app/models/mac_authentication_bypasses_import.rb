require "csv"

class MacAuthenticationBypassesImport
  attr_accessor :records

  CSV_HEADERS = "Address,Name,Description,Responses,Site".freeze

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  validate :validate_csv
  validate :validate_records
  validate :validate_sites

  def initialize(csv_contents = nil)
    @csv_contents = csv_contents
    @records = []
    @sites_not_found = []

    return unless valid_header?

    CSV.parse(csv_contents, headers: true).each do |row|
      address = row["Address"]
      name = row["Name"]
      description = row["Description"]
      responses = row["Responses"]
      site_name = row["Site"]

      site = Site.find_by(name: site_name)

      if site_name.present? && site.nil?
        @sites_not_found << site_name
      end

      record = MacAuthenticationBypass.new(
        name: name,
        address: address,
        description: description,
        site: site,
      )

      return @records << record if responses.nil?

      unwrap_responses(responses).each do |response|
        record.responses << response
      end

      @records << record
    end
  end

  def save
    return false unless valid?

    records_to_save = []
    responses_to_save = []
    last_id = MacAuthenticationBypass.last&.id || 0
    @records.each_with_index do |record, i|
      record_id = last_id + i + 1
      records_to_save << { id: record_id, address: record.address, name: record.name, description: record.description, site_id: record.site&.id }
      record.responses.each do |response|
        responses_to_save << { mac_authentication_bypass_id: record_id, response_attribute: response.response_attribute, value: response.value }
      end
    end

    MacAuthenticationBypass.insert_all(records_to_save)
    MabResponse.insert_all(responses_to_save)
  end

  def persisted?
    false
  end

  def headers
    CSV_HEADERS
  end

private

  def validate_csv
    return errors.add(:base, "CSV is missing") if @csv_contents.nil?

    errors.add(:base, "The CSV header is invalid") unless valid_header?
  end

  def validate_records
    @records.each_with_index do |record, i|
      record.validate

      record.errors.full_messages.each do |message|
        errors.add(:base, "Error on row #{i + 2}: #{message}")
      end

      record.responses.each do |response|
        response.errors.full_messages.each do |message|
          errors.add(:base, "Error on row #{i + 2}: #{message}")
        end
      end
    end
  end

  def validate_sites
    @sites_not_found.each do |site_name|
      errors.add(:base, "Site \"#{site_name}\" is not found")
    end
  end

  def unwrap_responses(responses)
    mab_responses = []
    responses = responses.split(";")
    responses.each do |r|
      response_attribute, value = r.split("=")
      mab_responses << MabResponse.new(response_attribute: response_attribute, value: value)
    end
    mab_responses
  end

  def valid_header?
    return false if @csv_contents.nil?

    @csv_contents.split("\n").first == CSV_HEADERS
  end
end
