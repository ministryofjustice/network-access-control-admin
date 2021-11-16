class DefaultFallbackFalsePolicies < ActiveRecord::Migration[6.1]
  def change
    change_table :policies do |t|
      t.change :fallback, :boolean, default: false
    end
  end
end
