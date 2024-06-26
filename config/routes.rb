Rails.application.routes.draw do
  root 'pages#index'

  resources :pages
  resources :links
  get '/courses' => 'pages#courses'

  # route for zoom meeting link
  # https://unm.zoom.us/my/ryans
  get '/zoom', to: redirect('https://unm.zoom.us/my/ryans')
end
