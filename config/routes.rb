Rails.application.routes.draw do

  root 'pages#index'

  get 'sc26', to: 'pages#sc26'
  get 'sc24', to: 'pages#sc24'
  get 'sc23', to: 'pages#sc23'
  get 'courses', to: 'pages#courses'
  get 'meet', to: 'pages#meet'
  # Route to show /app/assets/images/tesla-battery.png
  get 'tesla_battery', to: 'pages#tesla_battery'

  # route for dropbox resume pdf
  # get '/resume', to: redirect('https://www.dropbox.com/scl/fi/gvtppgbtwmum74o1j5a88/Ryan-Scherbarth-Resume.pdf?rlkey=vyygimwhisrypxhrwl948aey5&st=cx3tp0ls&dl=0')
  get '/resume', to: 'pages#resume'

  # route for zoom meeting link
  # https://unm.zoom.us/my/ryans
  get '/zoom', to: redirect('https://unm.zoom.us/my/ryans')

  get '/sitemap.xml', to: 'pages#sitemap', defaults: { format: 'xml' }

  # Hidden telemetry dashboard. Deliberately unlinked from anywhere on the
  # site and excluded from sitemap.xml and robots.txt.
  get '/metrics', to: 'metrics#index'
  get '/metrics/:id', to: 'metrics#show', as: :metric, constraints: { id: /\d+/ }

  # catch-all 404
  match '*path', to: 'pages#not_found', via: :all
end
