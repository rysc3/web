Rails.application.routes.draw do
  get 'pages/index'
  get 'pages/contact'

  resources :pages

  root 'pages#index'
end
