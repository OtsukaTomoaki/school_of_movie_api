Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  post '/auth/:provider/callback', to: 'sessions#create'
  namespace :api, {format: 'json'} do
    namespace :v1 do
      get 'users/avator_image_download', to: 'users#avator_image_download'
      resources :users

      resources :sessions
    end
  end
end
