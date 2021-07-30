class ValidateClientIpRangeUniqueness < ActiveRecord::Migration[6.1]
  def change
    change_column :clients, :ip_range, :string, unique: true
  end
end
