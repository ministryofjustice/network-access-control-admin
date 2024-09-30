class Site < ApplicationRecord
  paginates_per 50

  # Removing blank spaces from Site name entered
  before_validation :check_and_prompt_name_correction, if: -> { name.present? && (name.start_with?("FITS") || name.start_with?("MOJO")) && new_record? }
  before_validation :enforce_uppercase_prefix, if: -> { name.present? && new_record? }

  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }, unless: :skip_uniqueness_validation?
  validates :name, format: { with: /\AFITS-\d{4}-\w+-\w+\z/, message: "Site Name not in expected format : 'FITS-XXXX-TYPE-LOCATION'" }, if: -> { name.present? && name.start_with?("FITS") && new_record? }
  validates :name, format: { with: /\AMOJO-\d{4}-\w+-\w+\z/, message: "Site Name not in expected format : 'MOJO-XXXX-TYPE-LOCATION'" }, if: -> { name.present? && name.start_with?("MOJO") && new_record? }


  has_many :clients, dependent: :destroy
  has_many :mac_authentication_bypasses, dependent: :destroy
  has_many :site_policy
  has_many :policies, through: :site_policy, dependent: :destroy

  before_save :generate_tag, if: :new_record?
  after_create :create_fallback_policy
  after_update :update_fallback_policy

  audited

  def fallback_policy
    policies.where(fallback: true).first
  end

private

  def generate_tag
    self.tag = name.parameterize(separator: "_")
  end

  def create_fallback_policy
    return if policies.find_by(fallback: true)

    fallback_policy =
      Policy.new(
        name: "Fallback policy for #{name}",
        description: "Default fallback policy for #{name}",
        fallback: true,
        action: "reject",
      )
    if fallback_policy.save
      policies << fallback_policy
    else
      errors.add :name, "Failed to generate fallback policy with error: #{fallback_policy.errors.full_messages.join(', ')}"
      raise ActiveRecord::RecordInvalid
    end
  end

  def update_fallback_policy
    fallback_policy = policies.find_by(fallback: true)

    fallback_policy&.update(
      name: "Fallback policy for #{name}",
      description: "Default fallback policy for #{name}",
    )
  end

  def skip_uniqueness_validation?
    false
  end

  # rubocop:disable Lint/IneffectiveAccessModifier

  def self.ransackable_associations(_auth_object = nil)
    %w[audits clients mac_authentication_bypasses policies site_policy]
  end

  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id name policy_count tag updated_at]
  end

  # rubocop:enable Lint/IneffectiveAccessModifier

  def enforce_uppercase_prefix
    if name.present?
      suggested_name = name.sub(/\A(fits|mojo)/i) { |match| match.upcase }

      # Check if the name needs to be corrected
      if name != suggested_name
        errors.add(:name, "Suggested Name: '#{suggested_name}'. Please confirm if this is acceptable.")
        throw :abort
      end
    end
  end
  def check_and_prompt_name_correction
    cleaned_name = name.strip
    parts = cleaned_name.split('-').map(&:strip)

    if parts.length < 4
      errors.add(:name, "The name format is invalid. It should have at least 4 parts separated by dashes.")
      throw :abort
    end

    prefix = parts[0].upcase
    number = parts[1][0, 4].rjust(4, '0')
    # The third part should not be truncated
    service_type = parts[2]
    # The location part: replace spaces with underscores
    location = parts[3..].join('-').gsub(/\s+/, "_")

    corrected_name = "#{prefix}-#{number}-#{service_type}-#{location}"

    fits_format_regex = /\AFITS-\d{4}-\w+-\w+\z/
    mojo_format_regex = /\AMOJO-\d{4}-\w+-\w+\z/

    # Check format based on the prefix
    if prefix == "FITS" && corrected_name !~ fits_format_regex
      errors.add(:name, "Suggested Name: '#{corrected_name}'. Please confirm if this is acceptable. The name must follow the format: 'FITS-XXXX-TYPE-LOCATION'.")
      throw :abort
    elsif prefix == "MOJO" && corrected_name !~ mojo_format_regex
      errors.add(:name, "Suggested Name: '#{corrected_name}'. Please confirm if this is acceptable. The name must follow the format: 'MOJO-XXXX-TYPE-LOCATION'.")
      throw :abort
    end

    # Prompt name correction if the name doesn't match the corrected name
    if name != corrected_name
      errors.add(:name, "Suggested Name: '#{corrected_name}'. Please confirm if this is acceptable.")
      throw :abort
    else
      self.name = corrected_name
    end
  end
end
