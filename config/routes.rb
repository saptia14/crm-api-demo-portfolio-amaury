Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # ==========================================================================
  # API v1 Namespace
  # ==========================================================================

  # --- Authentication (Phase 2) ---
  scope :api do
    scope :v1 do
      devise_for :users,
                 controllers: {
                   sessions: "users/sessions",
                   registrations: "users/registrations"
                 },
                 path: "",
                 path_names: {
                   sign_in: "login",
                   sign_out: "logout",
                   registration: "signup"
                 }
    end
  end

  # --- CRM Resources (Phase 3) ---
  namespace :api do
    namespace :v1 do
      resources :companies do
        resources :notes, only: [:index, :create], module: false,
                  controller: "api/v1/notes"
      end

      resources :contacts do
        resources :notes, only: [:index, :create], module: false,
                  controller: "api/v1/notes"
      end

      resources :deals do
        resources :notes, only: [:index, :create], module: false,
                  controller: "api/v1/notes"
      end

      resources :notes, only: [:show, :update, :destroy]
      get 'users/me', to: 'users#me'
      resources :users, only: [:index, :show, :update] do
        resource :role, only: [:update], module: :users
      end
      resources :tenants, only: [:show]
      get 'analytics/revenue', to: 'analytics#revenue'
      get 'analytics/pipeline', to: 'analytics#pipeline'

      # --- Payments (Phase 6) ---
      post 'payments/process', to: 'payments#process_payment'
    end
  end
end
