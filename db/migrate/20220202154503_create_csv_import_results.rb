class CreateCsvImportResults < ActiveRecord::Migration[7.0]
  def change
    create_table :csv_import_results do |t|
      t.text :import_errors
      t.timestamps
    end
  end
end
