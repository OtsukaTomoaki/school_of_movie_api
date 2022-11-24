Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  get 'auth/:provider/callback', to: 'sessions#create'
  resources :sessions, only: %i[index new create destroy]
  namespace :api, {format: 'json'} do
    namespace :v1 do
      get 'users/avator_image_download', to: 'users#avator_image_download'
      post 'users/create_with_social_accounts', to: 'users#create_with_social_accounts'
      resources :users

      post 'sessions/remember_me', to: 'sessions#remember_me'
      resources :sessions
    end
  end
end
