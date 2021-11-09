class UpdateAttributeValueType < ActiveRecord::Migration[6.1]
  def change
    tables = %w[
      rules
      responses
    ]

    tables.each do |table|
      change_table table do |t|
        t.change :value, :text, null: false
        t.change :value, :text, null: false
      end
    end
  end
end
