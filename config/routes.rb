Rails.application.routes.draw do
  root 'pages#index'

  resources :pages
  resources :links
  get '/courses' => 'pages#courses'
  get '/cs491' => 'pages#cs491'

  # route for zoom meeting link
  # https://unm.zoom.us/my/ryans
  get '/zoom', to: redirect('https://unm.zoom.us/my/ryans')
end
