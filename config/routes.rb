Rails.application.routes.draw do

    resources :fax_requests do
	  collection do
	    post 'send_fax'
	  end
	end
    root 'fax_requests#index'
end
