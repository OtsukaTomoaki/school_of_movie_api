require "sidekiq/web"

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  mount ActionCable.server => '/cable'
  mount Sidekiq::Web => "/sidekiq"

  # root to: 'rooms#show'

  get 'auth/:provider/callback', to: 'sessions#create'
  resources :sessions, only: %i[index new create destroy]
  namespace :api, {format: 'json'} do
    namespace :v1 do
      get 'users/profile', to: 'users#profile'
      get 'users/download_avatar_image/:id', to: 'users#download_avatar_image'
      post 'users/create_with_social_accounts', to: 'users#create_with_social_accounts'
      resources :users

      get 'sessions/identity', to: 'sessions#identity'
      post 'sessions/remember_me', to: 'sessions#remember_me'

      resources :sessions

      resources :user_tags
      resources :talk_rooms
      resources :messages
      resources :movies
      resources :movie_genres
      resources :movie_user_likes
      resources :health_check, only: [:index]
      get 'movie_talk_rooms/:movie_id', to: 'movie_talk_rooms#by_movie_id'
      delete 'movie_user_likes', to: 'movie_user_likes#destroy'
      resources :background_jobs
    end
  end
end
