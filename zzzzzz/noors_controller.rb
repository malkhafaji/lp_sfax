class FaxRequestsController < ApplicationController
 require "./app/controllers/concerns/Fax.rb"
 before_action :set_fax_request, only: [:show, :edit, :update, :destroy]

 # GET /fax_requests
 # GET /fax_requests.json
 def index
   @fax_requests = FaxRequest.all
 end

 # GET /fax_requests/1
 # GET /fax_requests/1.json
 def show
 end

 # GET /fax_requests/new
 def new
   @fax_request = FaxRequest.new
 end

 # GET /fax_requests/1/edit
 def edit
 end

 # POST /fax_requests
 # POST /fax_requests.json
 #def create
   #fax_request = FaxRequest.new(fax_request_params)
   #fax_request.SendFaxQueueId=fax.body
   #client_receipt_date.created_at
   #fax_request.save

   #response,error_reason=send_fax(fax_request_params[:fax_number],"/home/developer/test2.txt",fax_request_params[:recipitent_name])

   #if !response
     #render json: reason
   #else
   #  render json: response
   #end

  # def noor_test
     #fax_request= FaxRequest.new(fax_number: d..s, sdf )
     #response = send_s_fax(fax_request)
     #render json: response


 def create

   response = send_fax(params)
   render json: response

 end

   # fax_request = FaxRequest.new(fax_request_params)
   # fax_request.SendFaxQueueId=fax.body
   # client_receipt_date.created_at
   # fax_request.save

   # response,error_reason=send_fax(fax_request_params[:fax_number],"/home/developer/test2.txt",fax_request_params[:recipient_name])

   # if !response
   #   render json: reason
   # else
   #   render json: response
   # end
   # respond_to do |format|
   #   format.html { redirect_to @fax_request, notice: 'Fax request was successfully created.' }
   #   format.json { render :show, status: :created, location: @fax_request }

   # end


 # PATCH/PUT /fax_requests/1
 # PATCH/PUT /fax_requests/1.json
 def update
   respond_to do |format|
     if @fax_request.update(fax_request_params)
       format.html { redirect_to @fax_request, notice: 'Fax request was successfully updated.' }
       format.json { render :show, status: :ok, location: @fax_request }
     else
       format.html { render :edit }
       format.json { render json: @fax_request.errors, status: :unprocessable_entity }
     end
   end
 end

 # DELETE /fax_requests/1
 # DELETE /fax_requests/1.json
 def destroy
   @fax_request.destroy
   respond_to do |format|
     format.html { redirect_to fax_requests_url, notice: 'Fax request was successfully destroyed.' }
     format.json { head :no_content }
   end
 end

 private
   # Use callbacks to share common setup or constraints between actions.
   def set_fax_request
     @fax_request = FaxRequest.find(params[:id])
   end

   # Never trust parameters from the scary internet, only allow the white list through.
   def fax_request_params
     params.require(:fax_request).permit(:fax_number, :file_name, :recipient_name, :client_receipt_date, :status, :message, :fax_vender_confirm_date, :queue_id, :send_confirm_date)
   end
 end
