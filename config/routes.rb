Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  devise_scope :user do
    get "users/sign_up/customer", to: "users/registrations#new_customer", as: :new_customer_registration
  end

  resources :admin, only: [ :index ]

  resources :deliveries, only: [ :index, :show ] do
    member do
      post :close
    end
    collection do
      get :load_truck
      get :start
    end
  end
  resources :companies, only: %i[new create edit update]
  resources :shipment_statuses, only: %i[new create edit update destroy]
  resources :shipment_action_preferences, only: %i[edit update]

  resources :shipments do
    member do
      get :copy
      post :close
    end
    collection do
      post :assign
      post :assign_shipments_to_truck
      post :initiate_delivery
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
