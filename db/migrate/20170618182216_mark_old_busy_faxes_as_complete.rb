class MarkOldBusyFaxesAsComplete < ActiveRecord::Migration[5.0]

    def up
    FaxRecord.has_send_error.each do |fax|
        puts "updating #{fax.id}"
        fax.update_attributes(record_completed: true)
      end
    end
    def down
      FaxRecord.has_send_error.each do |fax|
        puts "updating #{fax.id}"
        fax.update_attributes(record_completed: false)
      end
    end
end
