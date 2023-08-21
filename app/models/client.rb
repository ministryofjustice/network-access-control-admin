class Client < ApplicationRecord
  include ApplicationRecordHelper

  SHARED_SECRET_BYTES = 10
  RADSEC_SHARED_SECRET = "radsec".freeze

  belongs_to :site

  after_initialize :generate_shared_secret

  validates_presence_of :ip_range, :shared_secret
  validate :validate_ip
  validates :ip_range, presence: true, uniqueness: { scope: :radsec }, unless: :skip_validation?
  validate :validate_ip_range_overlap, on: %i[create update], unless: :skip_validation?

private

  def validate_ip
    return if ip_range.blank?

    unless valid_ip_range?(ip_range)
      return errors.add(:ip_range, "is invalid")
    end

    self.ip_range = format_ip_range(ip_range)
  end

  def validate_ip_range_overlap
    return if ip_range.blank? || errors[:ip_range].any?

    existing_clients = id.present? ? Client.where.not(id:) : Client.all
    existing_clients.each do |client|
      next unless IP::CIDR.new(ip_range).overlaps?(IP::CIDR.new(client.ip_range)) && radsec == client.radsec

      return errors.add(:ip_range, "IP overlaps with #{client.site.name} - #{client.ip_range}")
    end
  end

  def generate_shared_secret
    return if shared_secret.present?

    self.shared_secret = radsec? ? RADSEC_SHARED_SECRET : SecureRandom.hex(SHARED_SECRET_BYTES).upcase
  end

  def skip_validation?
    false
  end

  # rubocop:disable Lint/IneffectiveAccessModifier
  def self.ransackable_attributes(_auth_object = nil)
    %w[created_at id ip_range radsec shared_secret site_id updated_at]
  end
  # rubocop:enable Lint/IneffectiveAccessModifier

  audited
end
