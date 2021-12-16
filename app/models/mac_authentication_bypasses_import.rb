require "csv"

class MacAuthenticationBypassesImport
  attr_accessor :records

  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  validate :validate_records

  def initialize(csv_contents = {})
    @records = []

    return if csv_contents.empty?

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

      @records << record
    end
  end

  def validate_records
    @records.each do |record|
      record.validate
      record.errors.full_messages.each do |message|
        errors.add(:bypasses, message)
      end
    end
  end

  def persisted?
    false
  end
end
