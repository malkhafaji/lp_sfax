class MarkOldBusyFaxesAsComplete < ActiveRecord::Migration[5.0]

    def change
      FaxRecord.connection.schema_cache.clear!
      FaxRecord.reset_column_information
      puts "Updating #{FaxRecord.has_send_error.count} records"
      counter = 0
      FaxRecord.has_send_error.each do |fax|
        r = fax.update_attributes(record_completed: true)
        counter += 1 if r
        Rails.logger.info "updated record #{fax.id} - #{r}"
      end
      puts "#{counter} records has been updated"
    end
end
