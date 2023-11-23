Rails.application.routes.draw do

  # Define root route
  root 'pages#index'

  resources :pages

  # get 'pages/home'
  # get 'pages/contact'
end
