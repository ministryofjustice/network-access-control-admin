class UpdateDefaultsOnTimestamps < ActiveRecord::Migration[7.0]
  def change
    tables = %w[
      clients
      sites
      rules
      responses
      policies
      mac_authentication_bypasses
      site_policies
    ]

    tables.each do |table|
      change_table table do |t|
        t.change :created_at, :timestamp, default: -> { "CURRENT_TIMESTAMP()" }
        t.change :updated_at, :timestamp, default: -> { "CURRENT_TIMESTAMP()" }
      end
    end
  end
end
