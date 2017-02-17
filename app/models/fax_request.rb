class FaxRequest < ApplicationRecord

  validates :recipient_number,
              :numericality => {:only_integer => true,:message =>"It can't be other than numbers"},
              :length       => {minimum: 11, maximum: 11,:message => "It can't be more or less than 11 number"},
              :allow_blank  => false
    validates_presence_of :recipient_name,:message => "please fill the recipitent name"
    validates_presence_of :file_path,:message => "Upload file Can not be empty"
end
