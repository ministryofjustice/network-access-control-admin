class MacAuthenticationBypassesImport
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Naming

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
end
