class Rule < ApplicationRecord
  belongs_to :policy

  after_save :update_rule_count

  validates_presence_of :request_attribute, :operator, :value
  validates_inclusion_of :operator, in: %w[equals contains]

  audited

  private

  def update_rule_count
    policy.update_attribute(:rule_count, policy.rules.count)
  end
end
