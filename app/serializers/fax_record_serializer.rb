class FaxRecordSerializer < ActiveModel::Serializer
  attributes :id, :client_id, :recipient_number, :recipient_name, :attachments

  def attachments
    object.attachments.count
  end
end
