class DefaultsOnTimestamps < ActiveRecord::Migration[6.1]
  def change
    tables = %w[
      clients
      sites
      rules
      responses
      policies
      mac_authentication_bypasses
    ]

    tables.each do |table|
      change_table table do |t|
        t.change :created_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
        t.change :updated_at, :datetime, default: -> { "CURRENT_TIMESTAMP" }
      end
    end
  end
end
