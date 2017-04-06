Rails.application.routes.draw do
  resources :fax_records, only: [] do
    collection do
      match 'index', via: [:get, :post]
      post 'export' # Exporting the records as file
    end
  end
  root 'fax_records#index' # assigning the index page as the home page
  
  namespace :api do
  	namespace :v1 do
  		resources :fax_records, only: [] do
  		  collection do
  		    post 'send_fax' # Sending Faxes with recipient name ,Number and file path
  		  end
  		end
  	end
  end
  
  get 'run_tasks', to: 'application#run_tasks'
end
