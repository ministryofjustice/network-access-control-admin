class AddRuleCountToPolicies < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :rule_count, :integer, default: 0
  end
end
