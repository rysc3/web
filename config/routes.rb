Rails.application.routes.draw do

  root 'pages#index'

  get 'about', to: 'pages#about'
  get 'sc24', to: 'pages#sc24'
  get 'courses', to: 'pages#courses'

  # route for zoom meeting link
  # https://unm.zoom.us/my/ryans
  get '/zoom', to: redirect('https://unm.zoom.us/my/ryans')
end
