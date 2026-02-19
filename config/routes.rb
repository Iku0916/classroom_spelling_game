Rails.application.routes.draw do
  get 'password_resets/create'
  get 'password_resets/edit'
  get 'password_resets/update'
  get 'community/index'
  get "community/:id", to: "community#show", as: :community_kit
  get "onboardings", to: "onboardings#index"
  get 'users/new'
  get 'users/create'
  get 'home/index'
  root "home#index"
  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  resources :favorites, only: [:index]
  resources :password_resets, only: [:new, :create, :edit, :update]
  resources :onboardings, only: [:index] do
    post :complete
  end
  resource :user, only: [:show, :edit, :update]
  resources :participants, only: [:new, :create] do
    member do
      get :personal_result
    end
  end
  resources :word_kits, only: [:new, :create, :show, :index, :destroy, :edit, :update] do
    member do
      post :copy
    end
    resources :word_cards, only: [:new, :create, :index, :destroy, :edit, :update]
    resource :self_study, only: [:show, :update] do
      get :new, on: :collection
      get :play, on: :collection
      get :result, on: :collection
      post :answer, on: :collection
    end
    resource :favorite, only: [:create, :destroy]
  end
  resources :game_rooms, only: [:create, :show, :update] do
    member do
      get :waiting
      patch :start
      get :start
      post :join
      delete :finish
    end
    resource :game_play, only: [:show, :update] do
        post :answer
        patch :update_score
        post :finish
        get :overall_result
        get :personal_result
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  
  # Defines the root path route ("/")
  # root "posts#index"
end
