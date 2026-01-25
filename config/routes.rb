Rails.application.routes.draw do
  root "properties#index"

  resources :properties, only: [:index, :show] do
    resources :leads, only: [:create]
  end

  # SEO pages
  get '/about', to: 'pages#about'
  get '/contact', to: 'pages#contact'

  # Sitemap
  get '/sitemap.xml', to: redirect('https://ocnjweeklyrentals.com/sitemap.xml.gz')

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
