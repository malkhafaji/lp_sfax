class AttachmentSerializer < ActiveModel::Serializer
  attributes :id, :fax_record_id, :checksum, :file_id, :file_key
end
