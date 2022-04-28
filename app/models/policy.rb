class Policy < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }, unless: :skip_uniqueness_validation?
  validates_presence_of :description

  has_many :rules, dependent: :destroy
  has_many :responses, dependent: :destroy

  has_many :site_policy
  has_many :sites, through: :site_policy, dependent: :destroy

  after_save :ensure_policy_type_responses
  audited

  def default_reject?
    !default_accept?
  end

  def default_type
    default_accept? ? "accept" : "reject"
  end

private

  def skip_uniqueness_validation?
    false
  end

  def ensure_policy_type_responses
    responses.find_by(response_attribute: "Post-Auth-Type").try(:delete)
    if default_reject?
      responses << Response.create!(response_attribute: "Post-Auth-Type", value: "Reject")
    end
  end
end