Rails.application.routes.draw do
  get 'dashboard/home'

  root to: 'dashboard#home'

  get  'login', to: 'authentication#login_form', as: :login
  post 'login', to: 'authentication#login'

  get  'register', to: 'authentication#create_password_form'
  post 'register', to: 'authentication#create_password'

  get  'confirm', to: 'authentication#confirm_account_form'
  post 'confirm', to: 'authentication#confirm_account'

  get  'forgot', to: 'authentication#forgotten_password_form'
  post 'forgot', to: 'authentication#forgotten_password'

  get  'reset_password', to: 'authentication#reset_password_form'
  post 'reset_password', to: 'authentication#reset_password'

  get 'logout', to: 'authentication#logout_confirm'
  delete 'logout', to: 'authentication#logout'

  resources :people

  resources :groups do
    get 'invite', to: 'members#invite'
    post 'invite', to: 'members#process_invite'

    resources :members do
      post 'promote', to: 'members#promote', on: :member
      post 'demote', to: 'members#demote', on: :member
    end

    resources :activities do
      put 'presence', to: 'activities#presence', on: :member
      patch 'presence', to: 'activities#presence', on: :member
    end
  end
  get 'my_groups', to: 'groups#user_groups', as: :user_groups

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
