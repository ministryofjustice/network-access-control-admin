class AddFallbackToPoliciesTable < ActiveRecord::Migration[6.1]
  def change
    add_column :policies, :fallback, :bool, null: false
  end
end
