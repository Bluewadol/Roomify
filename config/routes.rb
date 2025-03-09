Rails.application.routes.draw do

  # root action: :index, controller: "railsui/default"
  root "home#index"

  devise_for :users

  resources :rooms, only: [:index, :show], controller: 'user/rooms'
  resources :reservations, controller: 'user/reservations'

  namespace :admin do
    resources :rooms do
      resources :room_amenities
      resources :reservations, only: [:show, :edit, :update, :destroy]
    end
    resources :reservations, only: [:new, :create]
  end

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

  if Rails.env.development?
    mount Railsui::Engine, at: "/railsui"
  end

  get "up" => "rails/health#show", as: :rails_health_check

end
