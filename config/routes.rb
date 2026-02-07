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
  end

  # SEO pages
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'
  post '/contact', to: 'pages#submit_contact'

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
