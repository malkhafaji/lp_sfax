Rails.application.routes.draw do
  resources :fax_records
  resources :fax_records do
    collection do
      post 'send_fax'
    end
  end
  root 'fax_records#index'
end
