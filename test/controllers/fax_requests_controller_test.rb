require 'test_helper'

class FaxRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @fax_request = fax_requests(:one)
  end

  test "should get index" do
    get fax_requests_url
    assert_response :success
  end

  test "should get new" do
    get new_fax_request_url
    assert_response :success
  end

  test "should create fax_request" do
    assert_difference('FaxRequest.count') do
      post fax_requests_url, params: { fax_request: { client_receipt_date: @fax_request.client_receipt_date, file_path: @fax_request.file_path, message: @fax_request.message, recipient_name: @fax_request.recipient_name, recipient_number: @fax_request.recipient_number, send_confirm_date: @fax_request.send_confirm_date, status: @fax_request.status, vendor_confirm_date: @fax_request.vendor_confirm_date } }
    end

    assert_redirected_to fax_request_url(FaxRequest.last)
  end

  test "should show fax_request" do
    get fax_request_url(@fax_request)
    assert_response :success
  end

  test "should get edit" do
    get edit_fax_request_url(@fax_request)
    assert_response :success
  end

  test "should update fax_request" do
    patch fax_request_url(@fax_request), params: { fax_request: { client_receipt_date: @fax_request.client_receipt_date, file_path: @fax_request.file_path, message: @fax_request.message, recipient_name: @fax_request.recipient_name, recipient_number: @fax_request.recipient_number, send_confirm_date: @fax_request.send_confirm_date, status: @fax_request.status, vendor_confirm_date: @fax_request.vendor_confirm_date } }
    assert_redirected_to fax_request_url(@fax_request)
  end

  test "should destroy fax_request" do
    assert_difference('FaxRequest.count', -1) do
      delete fax_request_url(@fax_request)
    end

    assert_redirected_to fax_requests_url
  end
end
