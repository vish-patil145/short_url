Rails.application.routes.draw do
  resources :campaigns, only: [:create, :index]
  get "/:slug", to: "redirects#show", as: :redirect, constraints: { slug: /[a-z0-9\-]+/ }
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
