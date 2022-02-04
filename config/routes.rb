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

  resources :mac_authentication_bypasses_imports

  resources :sites do
    resources :clients, except: %i[index show]
  end

  resources :sites_imports

  get "/sites/:id/policies", to: "sites#site_policies", as: "site_policies"
  post "/sites/:id/policies", to: "sites#attach_site_policies", as: "attach_site_policies"
  get "/sites/:id/policies/edit", to: "sites#edit_site_policies", as: "edit_site_policies"
  post "/sites/:id/policies/update", to: "sites#update_site_policies", as: "update_site_policies"

  get "/policies/:id/sites", to: "policies#policy_sites", as: "policy_sites"
  post "/policies/:id/sites", to: "policies#attach_policy_sites", as: "attach_policy_sites"

  resources :policies do
    resources :rules, except: :index
    resources :policy_responses, except: :index
  end

  get "/healthcheck", to: "monitoring#healthcheck"

  root "home#index"
  resources :audits, only: %i[index show]

  match "*path", via: :all, to: "application#error"
end
