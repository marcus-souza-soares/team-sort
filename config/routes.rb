Rails.application.routes.draw do
  resources :team_assignments
  resources :game_sessions do
    member do
      get :sort_teams_form
      post :sort_teams
      get :manage_players
      post :add_player
      delete :remove_player
    end
  end
  resources :teams
  resources :players
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "hello" => "hello#index"

  # Defines the root path route ("/")
  root "game_sessions#index"
end
