Rails.application.routes.draw do
  # resources :contacts
  # resources :data_sorts
  # resources :bookshelves
  # resources :calculator_apps
  # resources :portfolio_trackers

  # get 'pages/home'
  # get 'pages/resume'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  root 'pages#home'

  # Base Routes
  get '/contact', to: 'pages#contact', as: 'contact'
  get '/resume', to: 'pages#resume', as: 'resume'
  get '/index', to: 'pages#index', as: 'index'
  get '/schedule', to: 'pages#schedule', as: 'schedule'

  # Prog routes
  scope '/prog' do
    get '/portfolio_tracker', to: 'prog#portfolio_tracker', as: 'portfolio_tracker'
    get '/calculator_app', to: 'prog#calculator_app', as: 'calculator_app'
    get '/bookshelf', to: 'prog#bookshelf', as:'bookshelf'
    get '/data_sort', to: 'prog#data_sort', as: 'data_sort'
  end

  # ASUNM Example Site routes
  get '/asunm', to: 'asunm#home'
  get '/asunm/personnel', to: 'asunm#personnel'
  get '/asunm/information', to: 'asunm#information'
  # misc temp. routes
  # get '/vendor/animate.css/animate.min.css', to: 'assets#animate_css'
  get '/vendor/animate.css/animate.min.css', to: redirect('app/assets/vendor/animate.css/animate.min.css')
end
