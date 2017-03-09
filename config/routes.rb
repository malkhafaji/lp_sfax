Rails.application.routes.draw do
  resources :fax_records do
    collection do
      post 'send_fax'
      post 'index'
      get 'index'
    end
  end
  root 'fax_records#index'
end
