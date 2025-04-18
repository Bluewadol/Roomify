Rails.application.routes.draw do
  root "home#index"

  devise_for :users

  resources :rooms, only: [ :index, :show ], controller: "user/rooms", param: :slug

  resources :reservations, controller: "user/reservations", param: :slug do
    resource :check_in, only: [ :new, :create ], controller: "user/check_ins"
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :rooms, param: :slug do
      collection do
        get :download_all_qr_codes
      end
    end
    resources :reservations, param: :slug do
      resource :check_in, only: [ :new, :create ]
    end
  end

  resource :account, only: [ :show, :update ], controller: "user/account" do
    get "settings", to: "user/account#edit", as: :settings
  end

  if Rails.env.development?
    mount Railsui::Engine, at: "/railsui"
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
