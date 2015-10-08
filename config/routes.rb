Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions", passwords: 'users/passwords' }
  root 'home#index'
  ActiveAdmin.routes(self)
end
