require 'test_helper'

class FaxRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fax_record = fax_records(:one)
  end

  test "should get index" do
    get fax_records_url
    assert_response :success
  end

  test "should get new" do
    get new_fax_record_url
    assert_response :success
  end

  test "should create fax_record" do
    assert_difference('FaxRecord.count') do
      post fax_records_url, params: { fax_record: { SendFaxQueueId: @fax_record.SendFaxQueueId, attempts: @fax_record.attempts, barcode_items: @fax_record.barcode_items, client_receipt_date: @fax_record.client_receipt_date, error_code: @fax_record.error_code, fax_date_iso: @fax_record.fax_date_iso, fax_date_utc: @fax_record.fax_date_utc, fax_id: @fax_record.fax_id, fax_pages: @fax_record.fax_pages, fax_success: @fax_record.fax_success, file_path: @fax_record.file_path, is_success: @fax_record.is_success, max_fax_response_check_tries: @fax_record.max_fax_response_check_tries, message: @fax_record.message, message: @fax_record.message, out_bound_fax_id: @fax_record.out_bound_fax_id, pages: @fax_record.pages, recipient_fax: @fax_record.recipient_fax, recipient_name: @fax_record.recipient_name, recipient_number: @fax_record.recipient_number, result_code: @fax_record.result_code, result_message: @fax_record.result_message, send_confirm_date: @fax_record.send_confirm_date, send_fax_queue_id: @fax_record.send_fax_queue_id, sender_fax: @fax_record.sender_fax, status: @fax_record.status, tracking_code: @fax_record.tracking_code, vendor_confirm_date: @fax_record.vendor_confirm_date, watermark_id: @fax_record.watermark_id } }
    end

    assert_redirected_to fax_record_url(FaxRecord.last)
  end

  test "should show fax_record" do
    get fax_record_url(@fax_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_fax_record_url(@fax_record)
    assert_response :success
  end

  test "should update fax_record" do
    patch fax_record_url(@fax_record), params: { fax_record: { SendFaxQueueId: @fax_record.SendFaxQueueId, attempts: @fax_record.attempts, barcode_items: @fax_record.barcode_items, client_receipt_date: @fax_record.client_receipt_date, error_code: @fax_record.error_code, fax_date_iso: @fax_record.fax_date_iso, fax_date_utc: @fax_record.fax_date_utc, fax_id: @fax_record.fax_id, fax_pages: @fax_record.fax_pages, fax_success: @fax_record.fax_success, file_path: @fax_record.file_path, is_success: @fax_record.is_success, max_fax_response_check_tries: @fax_record.max_fax_response_check_tries, message: @fax_record.message, message: @fax_record.message, out_bound_fax_id: @fax_record.out_bound_fax_id, pages: @fax_record.pages, recipient_fax: @fax_record.recipient_fax, recipient_name: @fax_record.recipient_name, recipient_number: @fax_record.recipient_number, result_code: @fax_record.result_code, result_message: @fax_record.result_message, send_confirm_date: @fax_record.send_confirm_date, send_fax_queue_id: @fax_record.send_fax_queue_id, sender_fax: @fax_record.sender_fax, status: @fax_record.status, tracking_code: @fax_record.tracking_code, vendor_confirm_date: @fax_record.vendor_confirm_date, watermark_id: @fax_record.watermark_id } }
    assert_redirected_to fax_record_url(@fax_record)
  end

  test "should destroy fax_record" do
    assert_difference('FaxRecord.count', -1) do
      delete fax_record_url(@fax_record)
    end

    assert_redirected_to fax_records_url
  end
end
