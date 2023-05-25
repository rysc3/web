Rails.application.routes.draw do
  get 'pages/home'
  get 'pages/resume'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'pages#home'
  get '/resume', to: 'pages#resume'
  get '/index', to: 'pages#index'
end
