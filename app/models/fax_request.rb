class FaxRequest < ApplicationRecord

  # 
  # # Validate the recipient number to be only integers ,11 digit length and can not be empty
  # #----------------------------------------------------------------------------------------
  #   validates   :recipient_number,
  #               :numericality => {:only_integer => true,
  #                                 :message =>"It can't be other than numbers"},
  #               :length       => {:minimum => 11,
  #                                 :maximum => 11,
  #                                 :message => "It can't be more or less than 11 number"},
  #               :allow_blank  => false
  #
  #
  # # Validate the recipient name to not be empty
  # #-----------------------------------------------------------------------------------------
  #   validates_presence_of :recipient_name,
  #                         :message=> "Recipitent name can not be empty"
  #
  #
  #
  # # Validate the Uploaded file to not be empty
  # #-----------------------------------------------------------------------------------------
  #   validates_presence_of :file_path,
  #                         :message => "Attached file can not be empty"
  #

 end

