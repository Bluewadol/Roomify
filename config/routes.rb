Rails.application.routes.draw do

  namespace :rui do
    get "about", to: "pages#about"
    get "pricing", to: "pages#pricing"
    get "dashboard", to: "pages#dashboard"
    get "projects", to: "pages#projects"
    get "project", to: "pages#project"
    get "messages", to: "pages#messages"
    get "message", to: "pages#message"
    get "assignments", to: "pages#assignments"
    get "calendar", to: "pages#calendar"
    get "people", to: "pages#people"
    get "profile", to: "pages#profile"
    get "activity", to: "pages#activity"
    get "settings", to: "pages#settings"
    get "notifications", to: "pages#notifications"
    get "billing", to: "pages#billing"
    get "team", to: "pages#team"
    get "integrations", to: "pages#integrations"
  end

  # root action: :index, controller: "railsui/default"
  root "home#index"

  devise_for :users

  resources :rooms, only: [:index, :show], controller: 'user/rooms', param: :slug

  resources :reservations, controller: 'user/reservations', param: :slug do
    resource :check_in, only: [:new, :create, :show], controller: 'user/check_ins'
  end  

  namespace :admin do
    resources :rooms do
      resources :room_amenities
      resources :reservations, only: [:show, :edit, :update, :destroy]
    end
    resources :reservations, only: [:new, :create]
  end

  resources :profile, only: [:index, :edit, :update], controller: 'user/profile'

  if Rails.env.development?
    mount Railsui::Engine, at: "/railsui"
  end

  get "up" => "rails/health#show", as: :rails_health_check

end
