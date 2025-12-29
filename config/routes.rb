Rails.application.routes.draw do
  get 'users/new'
  get 'users/create'
  get 'home/index'
  root "home#index"
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  resources :participants, only: [:new, :create]
  resources :word_kits, only: [:new, :create, :show, :index, :destroy, :edit, :update] do
    resources :word_cards, only: [:new, :create, :index, :destroy, :edit, :update]
  end
  resources :game_rooms, only: [:update, :index, :create, :show] do
    member do
      patch :start
      get :waiting
      patch :finish
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
