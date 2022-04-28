class Policy < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }, unless: :skip_uniqueness_validation?
  validates_presence_of :description

  has_many :rules, dependent: :destroy
  has_many :responses, dependent: :destroy

  has_many :site_policy
  has_many :sites, through: :site_policy, dependent: :destroy

  audited

  def default_reject?
    responses.find_by(response_attribute: "Post-Auth-Type", value: "Reject") ? true : false
  end

  def default_accept?
    !default_reject?
  end

  def default_type
    default_accept? ? "accept" : "reject"
  end

private

  def skip_uniqueness_validation?
    false
  end
end
