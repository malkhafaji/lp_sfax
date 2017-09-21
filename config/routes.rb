Rails.application.routes.draw do

  root 'fax_records#homepage' # assigning the index page as the home page
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#logout', as: 'signout', via: [:get, :post]

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  get 'run_tasks', to: 'application#run_tasks'
  # get "fax_records/by_month" => "fax_records#by_month"

  resources :fax_records, only: [] do
    collection do
      get 'homepage'
      get 'report'
      get 'report_by_environment'
      get 'new_fax_records'
      match 'index', via: [:get, :post]
      post 'export' # Exporting the records as file
    end
  end

  namespace :api do
  	namespace :v1 do
  		resources :fax_records, only: [] do
  		  collection do
  		    post 'send_fax' # Sending Faxes with recipient name ,Number and file path
  		  end
  		end
  	end
  end

end
