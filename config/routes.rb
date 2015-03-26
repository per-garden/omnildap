Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  root 'home#index'
  match '/auth/:provider/callback' => 'authentications#create', as: 'omniauth', via: [:get, :post]
end
