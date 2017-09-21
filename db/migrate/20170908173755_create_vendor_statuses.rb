class CreateVendorStatuses < ActiveRecord::Migration[5.0]

  def change
    create_table :vendor_statuses do |t|
      t.string :service, index: true, null: false
      t.timestamps
    end
    #Addinf initial value for the vendor's server status 
    VendorStatus.create!(service: 'up')
  end
end
