class ChangeColumnTypeFromDateToDatetime < ActiveRecord::Migration[5.0]
  def up
    change_column :fax_records, :fax_date_utc, :datetime
    change_column :fax_records, :fax_date_iso, :datetime
  end

  def down
    change_column :fax_records, :fax_date_utc, :date
    change_column :fax_records, :fax_date_iso, :date
  end
end
