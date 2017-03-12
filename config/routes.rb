Rails.application.routes.draw do
  resources :fax_records do
    collection do
      post 'send_fax' # Sending Faxes with recipient name ,Number and file path
      post 'export' # Exporting the records as file
      post 'index'
      get 'index'

    end
  end
  root 'fax_records#index' # assigning the index page as the home page
end
