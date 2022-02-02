class AddCompletedAtToCsvImportResults < ActiveRecord::Migration[7.0]
  def change
    add_column :csv_import_results, :completed_at, :datetime, null: true
  end
end
