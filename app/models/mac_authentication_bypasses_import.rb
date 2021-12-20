require "csv"

class MacAuthenticationBypassesImport
  attr_accessor :records

  CSV_HEADERS = "Address,Name,Description,Responses,Site".freeze

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  validate :validate_header
  validate :validate_records

  def initialize(csv_contents = {})
    @csv_contents = csv_contents
    @records = []

    return if csv_contents.empty? || !valid_header?

    CSV.parse(csv_contents, headers: true).each do |row|
      address = row["Address"]
      name = row["Name"]
      description = row["Description"]
      responses = row["Responses"]
      site_name = row["Site"]

      record = MacAuthenticationBypass.new(
        name: name,
        address: address,
        description: description,
        site: Site.find_by(name: site_name),
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

    @records.each(&:save)
  end

  def persisted?
    false
  end

private

  def validate_header
    errors.add(:base, "The CSV header is invalid") unless valid_header?
  end

  def validate_records
    @records.each do |record|
      record.validate
      record.errors.full_messages.each do |message|
        errors.add(:base, message)
      end
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
    @csv_contents.split("\n").first == CSV_HEADERS
  end
end
