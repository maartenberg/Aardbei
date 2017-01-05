Rails.application.routes.draw do
  get 'dashboard/home'

  root to: 'dashboard#home'

  get  'login', to: 'authentication#login_form', as: :login
  post 'login', to: 'authentication#login'

  get  'register', to: 'authentication#create_password_form'
  post 'register', to: 'authentication#create_password'

  get  'forgot', to: 'authentication#forgotten_password_form'
  post 'forgot', to: 'authentication#forgotten_password'

  get 'logout', to: 'authentication#logout_confirm'
  delete 'logout', to: 'authentication#logout'

  resources :people

  resources :groups do
    resources :members
    resources :activities do
      put 'presence', to: 'activities#presence', on: :member
      patch 'presence', to: 'activities#presence', on: :member
    end
  end
  get 'my_groups', to: 'groups#user_groups', as: :user_groups

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
