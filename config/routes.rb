Rails.application.routes.draw do
  root 'pages#index'

  resources :pages
  resources :links
  get '/courses' => 'pages#courses'
  # get '/resume', to: redirect('https://www.dropbox.com/scl/fi/gvtppgbtwmum74o1j5a88/Ryan-Scherbarth-Resume.pdf?rlkey=vyygimwhisrypxhrwl948aey5&st=cx3tp0ls&dl=0')
  get 'sc24' => 'pages#sc24'


  # route for zoom meeting link
  # https://unm.zoom.us/my/ryans
  get '/zoom', to: redirect('https://unm.zoom.us/my/ryans')
end
