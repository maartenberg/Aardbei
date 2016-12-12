Rails.application.routes.draw do
  get  'login', to: 'authentication#login_form'
  post 'login', to: 'authentication#login'

  get  'register', to: 'authentication#create_password_form'
  post 'register', to: 'authentication#create_password'

  get  'forgot', to: 'authentication#forgotten_password_form'
  post 'forgot', to: 'authentication#forgotten_password'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
