Rails.application.routes.draw do
  #get 'sessions/new'
  root to: 'static#index'

  get '/api' => redirect('/swagger/dist/index.html?url=/api-docs.json')

  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'

  get '/feed', to: 'static#feed'

  resources :comments
  resources :posts
  resources :profiles
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
