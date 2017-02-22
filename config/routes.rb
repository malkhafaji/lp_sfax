Rails.application.routes.draw do

  resources :fax_requests
  root 'fax_requests#index'
end
