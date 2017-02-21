Rails.application.routes.draw do

  resources :fax_requests do
    collection do
      get 'fax_req'
    end
  end
  root 'fax_requests#fax_req'

end
