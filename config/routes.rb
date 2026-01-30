Rails.application.routes.draw do
  root "properties#index"

  resources :properties, only: [:index, :show] do
    resources :leads, only: [:create]
  end

  resources :neighborhoods, only: [:index, :show]
  resources :guides, only: [:index, :show]

  # SEO pages
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
