require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => "/sidekiq"

  root to: 'rooms#show'

  get 'auth/:provider/callback', to: 'sessions#create'
  resources :sessions, only: %i[index new create destroy]
  namespace :api, {format: 'json'} do
    namespace :v1 do
      get 'users/profile', to: 'users#profile'
      get 'users/download_avatar_image', to: 'users#download_avatar_image'
      post 'users/create_with_social_accounts', to: 'users#create_with_social_accounts'
      resources :users

      post 'sessions/remember_me', to: 'sessions#remember_me'
      resources :sessions

      resources :user_tags
      resources :talk_rooms
      resources :messages
      resources :movies
      resources :movie_genres

      post 'movie_user_likes', to: 'movie_user_likes#create'

      resources :background_jobs
    end
  end
end
