class Policy < ApplicationRecord
  paginates_per 50

  validates :name, presence: true, uniqueness: { case_sensitive: false }, unless: :skip_uniqueness_validation?
  validates_presence_of :description

  has_many :rules, dependent: :destroy
  has_many :responses, dependent: :destroy

  has_many :site_policy
  has_many :sites, through: :site_policy, dependent: :destroy

  audited

private

  def skip_uniqueness_validation?
    false
  end
end
