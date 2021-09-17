Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    get "sign_in", to: "devise/sessions#new", as: :new_user_session
    match "sign_out", to: "devise/sessions#destroy", as: :destroy_user_session, via: %i[get delete]
  end

  resources :certificates

  resources :mac_authentication_bypasses do
    resources :mab_responses
  end

  resources :sites do
    resources :clients, except: %i[index show]
  end

  get "/sites/:id/policies", to: "sites#policies", as: "site_policies"
  post "/sites/:id/policies", to: "sites#attach_policies"
  get "/sites/:id/policies/edit", to: "sites#edit_policies", as: "edit_site_policies"
  post "/sites/:id/policies/update", to: "sites#update_policies", as: "update_site_policies"

  resources :policies do
    resources :rules
    resources :policy_responses
  end

  get "/healthcheck", to: "monitoring#healthcheck"

  root "home#index"
  resources :audits, only: %i[index show]
end
