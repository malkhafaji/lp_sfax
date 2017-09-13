class CreateCallbackParams < ActiveRecord::Migration[5.0]
  def change
    create_table :callback_params do |t|
      t.references :fax_record, foreign_key: true, index: true
      t.integer :let_sk
      t.integer :e_sk
      t.integer :type_cd_sk
      t.integer :priority_cd_sk
      t.timestamps
    end
  end
end
