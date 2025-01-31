Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  resources :admin, only: [ :index ]

  resources :deliveries, only: [ :index ] do
    collection do
      get :truck_loading
    end
  end
  resources :companies, only: %i[new create edit update]
  resources :shipment_statuses, only: %i[new create edit update destroy]
  resources :shipments do
    collection do
      post :assign
      post :assign_shipments_to_truck
    end
  end
  resources :trucks, only: %i[show new create edit update destroy]
  resources :driver_managements, only: [ :new, :create, :edit, :update ]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "welcome#index"
end
