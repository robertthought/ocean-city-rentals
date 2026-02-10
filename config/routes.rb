Rails.application.routes.draw do
  root "properties#index"

  resources :properties, only: [:index, :show] do
    collection do
      get :search
    end
    resources :leads, only: [:create]
  end

  resources :neighborhoods, only: [:index, :show]
  resources :guides, only: [:index, :show]

  # Owner Authentication
  get '/owner/login', to: 'owner/sessions#new', as: :owner_login
  post '/owner/login', to: 'owner/sessions#create'
  delete '/owner/logout', to: 'owner/sessions#destroy', as: :owner_logout

  get '/owner/register', to: 'owner/registrations#new', as: :owner_register
  post '/owner/register', to: 'owner/registrations#create'

  get '/owner/forgot-password', to: 'owner/passwords#new', as: :owner_forgot_password
  post '/owner/forgot-password', to: 'owner/passwords#create'
  get '/owner/reset-password/:token', to: 'owner/passwords#edit', as: :owner_reset_password
  patch '/owner/reset-password/:token', to: 'owner/passwords#update'

  # Claim property flow (public - combines registration + claim)
  get '/owner/claim/:id', to: 'owner/claims#claim_property', as: :owner_claim_property
  post '/owner/claim/:id', to: 'owner/claims#create_claim_with_registration'

  # Owner Portal (authenticated)
  namespace :owner do
    root to: 'dashboard#index'

    resource :profile, only: [:show, :edit, :update]

    resources :claims, only: [:index, :new, :create] do
      get :search_properties, on: :collection
    end

    resources :properties, only: [:index, :show, :edit, :update] do
      member do
        get :analytics
      end
      resources :photos, only: [:create, :destroy], controller: 'property_photos'
    end
  end

  # Admin
  namespace :admin do
    root to: "dashboard#index"
    resources :leads, only: [:index, :show, :destroy] do
      post :mark_contacted, on: :member
      get :export, on: :collection
    end
    resources :contact_submissions, only: [:index, :show] do
      post :mark_responded, on: :member
      get :export, on: :collection
    end
    resources :ownership_claims, only: [:index, :show] do
      member do
        post :approve
        post :reject
      end
    end
    resources :property_submissions, only: [:index, :show] do
      post :mark_reviewed, on: :member
      get :export, on: :collection
    end
    get :analytics, to: "analytics#index"
  end

  # SEO pages
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'
  post '/contact', to: 'pages#submit_contact'
  get '/list-property', to: 'pages#list_property'
  post '/list-property', to: 'pages#submit_property'
  get '/pricing', to: 'pages#pricing'

  # Checkout
  get '/checkout', to: 'checkouts#new', as: :new_checkout
  post '/checkout', to: 'checkouts#create', as: :checkout
  get '/checkout/success', to: 'checkouts#success', as: :checkout_success

  # Webhooks
  post '/webhooks/stripe', to: 'webhooks/stripe#create'

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
