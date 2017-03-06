class FaxRecordsController < ApplicationController
  before_action :set_fax_record, only: [:show, :edit, :update, :destroy]

  # GET /fax_records
  # GET /fax_records.json
  def index
    @fax_records = FaxRecord.all
  end

  # GET /fax_records/1
  # GET /fax_records/1.json
  def show
  end

  # GET /fax_records/new
  def new
    @fax_record = FaxRecord.new
  end

  # GET /fax_records/1/edit
  def edit
  end

  # POST /fax_records
  # POST /fax_records.json
  def create
    @fax_record = FaxRecord.new(fax_record_params)

    respond_to do |format|
      if @fax_record.save
        format.html { redirect_to @fax_record, notice: 'Fax record was successfully created.' }
        format.json { render :show, status: :created, location: @fax_record }
      else
        format.html { render :new }
        format.json { render json: @fax_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fax_records/1
  # PATCH/PUT /fax_records/1.json
  def update
    respond_to do |format|
      if @fax_record.update(fax_record_params)
        format.html { redirect_to @fax_record, notice: 'Fax record was successfully updated.' }
        format.json { render :show, status: :ok, location: @fax_record }
      else
        format.html { render :edit }
        format.json { render json: @fax_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fax_records/1
  # DELETE /fax_records/1.json
  def destroy
    @fax_record.destroy
    respond_to do |format|
      format.html { redirect_to fax_records_url, notice: 'Fax record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fax_record
      @fax_record = FaxRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fax_record_params
      params.require(:fax_record).permit(:recipient_name, :recipient_number, :file_path, :client_receipt_date, :status, :SendFaxQueueId, :message, :max_fax_response_check_tries, :send_confirm_date, :vendor_confirm_date, :send_fax_queue_id, :is_success, :result_code, :error_code, :result_message, :recipient_fax, :tracking_code, :fax_date_utc, :fax_id, :pages, :attempts, :sender_fax, :barcode_items, :fax_success, :out_bound_fax_id, :fax_pages, :fax_date_iso, :watermark_id, :message)
    end
end
