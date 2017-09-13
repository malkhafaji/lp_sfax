class CallbackParam < ApplicationRecord
  belongs_to :fax_record
  validates_presence_of :let_sk, :e_sk, :type_cd_sk, :priority_cd_sk, :fax_record_id
end
