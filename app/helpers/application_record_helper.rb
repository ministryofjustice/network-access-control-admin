module ApplicationRecordHelper
  def trim_white_space(*attr)
    attr.each { |a| a.strip! if a.present? }
  end

  def validate_radius_attribute(attribute, value, operator = nil)
    return if attribute.blank? || errors.key?(attribute.to_sym)

    result = UseCases::ValidateRadiusAttribute.new.call(attribute: attribute, value: value, operator: operator)

    unless result.fetch(:success)
      errors.add(:base, result.fetch(:message))
    end
  end
end
