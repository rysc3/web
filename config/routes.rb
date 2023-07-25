Rails.application.routes.draw do
  root 'pages#home'

  resources :tests
  resources :pages
  resources :docs
  resources :prog

  # Base Routes
  get '/resume', to: 'pages#resume', as: 'resume'
  get '/really_long_path_for_the_best_cable_management_ever', to: 'pages#photos', as: 'photos'
  get '/easy', to: 'pages#photos', as: 'easy_photos'

  # ASUNM Example Site routes
  # get '/asunm', to: 'asunm#home'
  # get '/asunm/personnel', to: 'asunm#personnel'
  # get '/asunm/information', to: 'asunm#information'
end
