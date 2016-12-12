Rails.application.routes.draw do
  get 'login', to: 'authentication#login'

  get 'authentication/create_password'

  get 'authentication/forgotten_password'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
