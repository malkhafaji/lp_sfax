require 'rails_helper'

RSpec.describe 'FaxResponseRake', type: :rake do

 all_params_list = FaxRecord.all


  describe "should incloude all the params and update" do
   it 'should update SendFaxQueueId' do
      expect(all_params_list.grep('SendFaxQueueId')) ==(['SendFaxQueueId'])
    end
  end

describe "should incloude all the params and update" do
   it 'should update IsSuccess' do
      expect(all_params_list.grep('IsSuccess')) ==(['IsSuccess'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update ResultCode' do
      expect(all_params_list.grep('ResultCode')) ==(['ResultCode'])
    end
  end

 describe "should incloude all the params and update" do
   it 'should update ErrorCode' do
      expect(all_params_list.grep('ErrorCode')) ==(['ErrorCode'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update ResultMessage' do
      expect(all_params_list.grep('ResultMessage')) ==(['ResultMessage'])
    end
  end

 describe "should incloude all the params and update" do
   it 'should update RecipientName' do
      expect(all_params_list.grep('RecipientName')) ==(['RecipientName'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update RecipientFax' do
      expect(all_params_list.grep('RecipientFax')) ==(['RecipientFax'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update TrackingCode' do
      expect(all_params_list.grep('TrackingCode')) ==(['TrackingCode'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update FaxDateUtc' do
      expect(all_params_list.grep('FaxDateUtc')) ==(['FaxDateUtc'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update FaxId' do
      expect(all_params_list.grep('FaxId')) ==(['FaxId'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update Pages' do
      expect(all_params_list.grep('Pages')) ==(['Pages'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update Attempts' do
      expect(all_params_list.grep('Attempts')) ==(['Attempts'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update SenderFax' do
      expect(all_params_list.grep('SenderFax')) ==(['SenderFax'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update BarcodeItems' do
      expect(all_params_list.grep('BarcodeItems')) ==(['BarcodeItems'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update FaxSuccess' do
      expect(all_params_list.grep('FaxSuccess')) ==(['FaxSuccess'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update OutBoundFaxId' do
      expect(all_params_list.grep('OutBoundFaxId')) ==(['OutBoundFaxId'])
    end
  end

  describe "should incloude all the params  and update" do
   it 'should update FaxPages' do
      expect(all_params_list.grep('FaxPages')) ==(['FaxPages'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update FaxDateIso' do
      expect(all_params_list.grep('FaxDateIso')) ==(['FaxDateIso'])
    end
  end

describe "should incloude all the params and update" do
   it 'should update WatermarkId' do
      expect(all_params_list.grep('WatermarkId')) ==(['WatermarkId'])
    end
  end

  describe "should incloude all the params and update" do
   it 'should update message' do
      expect(all_params_list.grep('message')) ==(['message'])
    end
  end


end
