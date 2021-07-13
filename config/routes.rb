Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    get "sign_in", to: "devise/sessions#new", as: :new_user_session
    match "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session, via: %i[get delete]
  end

  resources :sites, :vlans
  resources :policies do
    resources :rules
    resources :responses
  end

  get "/healthcheck", to: "monitoring#healthcheck"

  root "home#index"
  resources :audits, only: %i[index show]
end
